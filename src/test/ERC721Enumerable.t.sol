pragma solidity ^0.8.10;
import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {ERC721, ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC721Enumerable} from "../tokens/ERC721/ERC721Enumerable.sol";
import {ERC721User} from "solmate/test/utils/users/ERC721User.sol";

contract ERC721Recipient is ERC721TokenReceiver {
    address public operator;
    address public from;
    uint256 public id;
    bytes public data;

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _id,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        operator = _operator;
        from = _from;
        id = _id;
        data = _data;

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

contract MockERC721Enumerable is ERC721Enumerable {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function tokenURI(uint256) public pure virtual override returns (string memory) {}

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        _safeMint(to, tokenId, data);
    }
}

contract ERC721EnumerableTest is DSTestPlus {
    MockERC721Enumerable token;

    function setUp() public {
        token = new MockERC721Enumerable("Token", "TKN");
    }

    function testMetadata() public {
        assertEq(token.name(), "Token");
        assertEq(token.symbol(), "TKN");
    }

    function testMint() public {
        token.mint(address(0xDAD), 42);

        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(address(0xDAD)), 1);
        assertEq(token.ownerOf(42), address(0xDAD));
        assertEq(token.tokenByIndex(0), 42);
        assertEq(token.tokenOfOwnerByIndex(address(0xDAD), 0), 42);
    }

    function testBurn() public {
        token.mint(address(0xDaD), 42);
        token.burn(42);

        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(address(0xDAD)), 0);
        assertEq(token.ownerOf(42), address(0));
    }

    function testTransferFrom() public {
        ERC721User from = new ERC721User(token);

        token.mint(address(from), 42);

        from.approve(address(this), 42);

        token.transferFrom(address(from), address(0xDAD), 42);

        assertEq(token.totalSupply(), 1);
        assertEq(token.ownerOf(42), address(0xDAD));
        assertEq(token.balanceOf(address(0xDAD)), 1);
        assertEq(token.balanceOf(address(from)), 0);
        assertEq(token.tokenByIndex(0), 42);
        assertEq(token.tokenOfOwnerByIndex(address(0xDAD), 0), 42);
    }

    function testMintMultiple() public {
        token.mint(address(0xDAD), 42);
        token.mint(address(0xFADE), 2001);
        token.mint(address(0xDAD), 451);

        assertEq(token.totalSupply(), 3);
        assertEq(token.tokenByIndex(1), 2001);
        assertEq(token.tokenOfOwnerByIndex(address(0xDAD), 1), 451);
    }

    function testBurnNotLast() public {
        token.mint(address(0xDAD), 42);
        token.mint(address(0xDAD), 451);
        token.burn(42);

        assertEq(token.totalSupply(), 1);
        assertEq(token.tokenByIndex(0), 451);
        assertEq(token.tokenOfOwnerByIndex(address(0xDAD), 0), 451);
    }
}
