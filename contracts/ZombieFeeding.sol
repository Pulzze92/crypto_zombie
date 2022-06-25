import "./ZombieFactory.sol";

contract KittyInterface {
function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes);
}

contract ZombieFeeding is ZombieFactory {
    KittyInterface kittyContract;
    
    function setKittyContractAddress (address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
}

function _triggerCooldown (Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
}

function _isReady (Zombie storage _zombie) internal view returns (bool) {
    return(_zombie.readyTime <= now);
}

function feedAndMultiply (uint _zombieId, uint _targetDna, string _species) internal {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];

    require(_isReady(myZombie));

    _targetDna = _targetDna % dnaModulus; //убедиться, что _targetDna не длиннее, чем 16 цифр.% чтобы взять только последние 16 цифр.
    uint newDna = (myZombie.dna + _targetDna) / 2;

    if(keccak256(_species) == keccak256("kitty")) {
          newDna = newDna - newDna % 100 + 99; // мы хотим заменить последние 2 цифры ДНК на 99
          //предположим, newDna равна 334455. Тогда newDna % 100 равна 55, поэтому newDna - newDna % 100 это 334400. 
          //В конце добавим 99 чтобы получить 334499.
    }
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
}

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
    }

}