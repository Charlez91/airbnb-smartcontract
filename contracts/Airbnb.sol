// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Airbnb is Ownable{
    string public contractName;
    address private _owner;
    uint private rentalId;
    uint256[] public rentalIds;

    using Counters for Counters.Counter;
    Counters.Counter private _rentalIds;

    constructor(string memory _name){
        contractName = _name;//"Airbnb Clone Smart Contract";
        _owner = msg.sender;
    }

    struct RentalInfo {
        uint256 id;
        string name;
        string city;
        string lat;
        string long;
        string unoDescription;
        string dosDescription;
        string imgUrl;
        uint256 maxGuests;
        uint256 pricePerDay;
        string[] datesBooked;
        address renter;
    }

    event rentalCreated (
        string name,
        string city,
        string lat,
        string long,
        string unoDescription,
        string dosDescription,
        string imgUrl,
        uint256 maxGuests,
        uint256 pricePerDay,
        string[] datesBooked,
        uint256 id,
        address renter
    );

    event newDatesBooked (
        string[] datesBooked,
        uint256 id,
        address booker,
        string city,
        string imgUrl 
    );

    mapping(uint256=>RentalInfo) private rentals;

    function addRentals(
        string memory name,
        string memory city,
        string memory lat,
        string memory long,
        string memory unoDescription,
        string memory dosDescription,
        string memory imgUrl,
        uint256 maxGuests,
        uint256 pricePerDay,
        string[] memory datesBooked
    ) public onlyOwner {
        require(msg.sender != address(0x0), "Address must be a legitimate address");
        require(bytes(name).length > 0, "Name has to be passed in");
        require(bytes(city).length > 0, "City has to exist");
        require(bytes(lat).length > 0, "latitude has to be passed in");
        require(bytes(long).length > 0, "longitude has to exist");
        require(pricePerDay > 0, "Price Per Day has to be passed in");
        require(bytes(unoDescription).length > 0, "unoDescription has to exist");
        require(bytes(dosDescription).length > 0, "doDescription has to be passed in");

        _rentalIds.increment();
        rentalId = _rentalIds.current();
        RentalInfo storage newRental = rentals[rentalId];
        newRental.name = name;
        newRental.city = city;
        newRental.lat = lat;
        newRental.long = long;
        newRental.unoDescription = unoDescription;
        newRental.dosDescription = dosDescription;
        newRental.imgUrl = imgUrl;
        newRental.maxGuests = maxGuests;
        newRental.pricePerDay = pricePerDay;
        newRental.datesBooked = datesBooked;
        newRental.id = rentalId;
        newRental.renter = _owner;
        rentalIds.push(rentalId);
        emit rentalCreated(
                name, 
                city, 
                lat, 
                long, 
                unoDescription, 
                dosDescription, 
                imgUrl, 
                maxGuests, 
                pricePerDay, 
                datesBooked, 
                rentalId, 
                _owner);
        
        }
    

    function checkBookings(uint256 id, string[] memory newBookings) private view returns (bool){
        require(id>0 && id<rentalId,"Id must be valid and not greater than max id");

        for (uint i = 0; i < newBookings.length; i++) {
            for (uint j = 0; j < rentals[id].datesBooked.length; j++) {
                if (keccak256(abi.encodePacked(rentals[id].datesBooked[j])) == keccak256(abi.encodePacked(newBookings[i]))) {
                    return false;
                }
            }
        }
        return true;
    }

    function addDatesBooked(uint256 id, string[] memory newBookings) public payable {
        require(id < rentalId, "No such Rental");
        require(checkBookings(id, newBookings), "Already Booked For Requested Date");
        require(msg.value == (rentals[id].pricePerDay * 1 ether * newBookings.length) , "Please submit the asking price in order to complete the purchase");
    
        for (uint i = 0; i < newBookings.length; i++) {
            rentals[id].datesBooked.push(newBookings[i]);
        }

        payable(_owner).transfer(msg.value);//youcan store payment @contract address. and withdraw when you feel by adding a withdrawing function
        emit newDatesBooked(newBookings, id, msg.sender, rentals[id].city,  rentals[id].imgUrl);
    }

    function getRental(uint256 id) public view returns (string memory, uint256, string[] memory){
        require(id < rentalId, "No such Rental");

        RentalInfo storage s = rentals[id];
        return (s.name,s.pricePerDay,s.datesBooked);
    }

    function getRental() public view returns (RentalInfo[] memory){
        uint itemCount = _rentalIds.current();
        uint currentIndex = 0;

        RentalInfo[] memory allrentals = new RentalInfo[](itemCount);
        for (uint i = 0; i < itemCount; i++) {
            uint currentId = i + 1;//cant start with a zero cos counters started with 1
            RentalInfo storage currentItem = rentals[currentId];//looks up the post by the uint id or indexed integer
            allrentals[currentIndex] = currentItem;//puts in the post object by there index starting from zero into the list
            currentIndex += 1;//increases the index by 1 after each loop
        }
        return allrentals;
    }



}