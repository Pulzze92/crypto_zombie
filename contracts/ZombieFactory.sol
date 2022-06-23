//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract ZombieFactory {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10**dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

//Можно задать массив как public (открытый), и Solidity автоматически создаст для него 
//геттер (способ получения).
//В этом случае другие контракты смогут читать этот массив (но не писать в него). 
//Это образец хранения открытых данных в контракте.
    Zombie[] public zombies;

    mapping(uint => address) public zombieToOwner; // отслеживает адрес, которому принадлежит зомби
    mapping(address => uint) ownerZombieCount; // отслеживает, сколькими зомби владеет пользователь

    function _createZombie(string _name, uint _dna) private { //создать зомби
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        zombieToOwner[id] = msg.sender; // когда мы получим id нового зомби, обновим нашу карту соответсвий zombieToOwner, чтобы сохранить msg.sender под этим id.
        ownerZombieCount[msg.sender]++; // увеличим ownerZombieCount для этого msg.sender.
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns(uint) { //генерирует случайный номер ДНК из строки.
        uint rand = uint(keccak256(_str));

        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerZombieCount[msg.sender] == 0, "You are already have a zombie!");
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
