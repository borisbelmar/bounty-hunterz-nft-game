// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BountyHunterz {
  uint256 public constant MIN_BOUNTY = 1 * 10 ** 18;
  uint8 public constant HOST_FEE = 2;
  uint8 public constant LIQUIDITY_FEE = 8;
  uint8 public constant BASE_BURN_THREAT_PERCENT = 50;
  uint8 public constant BURN_PERCENT_PER_WIN = 10;
  uint8 public constant PLEDGE_TICKET_PERCENT = 5;
  uint8 public constant MAX_TICKETS_BY_COVENANT = 10;
  uint8 public constant MAX_TICKETS_BY_STRIKE = 100;
  uint8 public constant THREAT_LOST_PAY_PLEDGE_PERCENT = 20;

  enum StrikeStatus {
    OPEN,
    HUNTERZ,
    THREAT
  }

  struct Threat {
    address owner;
    uint256 bounty;
    uint256 totalWins;
    bool alive;
  }

  struct Hunter {
    address owner;
    uint256 totalPledge;
    uint256 totalAttempts;
    uint256 totalWins;
  }

  struct Covenant {
    uint256 strikeIndex;
    address leader;
    uint256 pledge;
    bool open;
  }

  struct Strike {
    uint256 totalPledge;
    uint256 threatId;
    uint256 winnerCovenantId;
    uint256 bounty;
    StrikeStatus status;
  }

  uint256 public maxThreats;
  uint256 public liquidity;
  address public host;

  uint256 public threatsCount;
  uint256 public threatsAlive;
  mapping (uint256 => bool) public existentThreats;
  mapping (uint256 => Threat) public threats;
  mapping (uint256 => bool) public blockedThreats;

  mapping (uint256 => bool) public existentHunterz;
  mapping (uint256 => Hunter) public hunterz;
  mapping (uint256 => bool) public blockedHunterz;
  mapping (uint256 => uint256) public hunterzActiveCovenant;

  Strike[] public strikes;
  Covenant[] public covenants;
  mapping (uint256 => uint256[]) public strikeCovenants;
  mapping (uint256 => uint256[]) public covenantsHunterz;
  
  constructor() {
    liquidity = 0;
    host = msg.sender;
  }

  modifier onlyHost {
    require(
      msg.sender == host,
      "Just the host can use this method"
    );
    _;
  }

  modifier onlyThreatOwner(uint256 _threatId) {
    require(
      msg.sender == threats[_threatId].owner,
      "Just the threat owner can use this method"
    );
    _;
  }

  modifier onlyHunterOwner(uint256 _hunterId) {
    require(
      msg.sender == hunterz[_hunterId].owner,
      "Just the hunter owner can use this method"
    );
    _;
  }

  modifier activeThreat(uint256 _threatId) {
    require(
      !blockedThreats[_threatId] && threats[_threatId].alive,
      "This threat is blocked or dead"
    );
    _;
  }

  modifier activeHunter(uint256 _hunterId) {
    require(
      !blockedHunterz[_hunterId],
      "This hunter is blocked"
    );
    _;
  }

  modifier openStrike(uint256 _strikeIndex) {
    require(
      strikes[_strikeIndex].status == StrikeStatus.OPEN,
      "This strike is closed or non exists"
    );
    _;
  }

  function addLiquidity() external payable {
    liquidity += msg.value;
  }

  // FIXME: Just fot debug purposes
  function withdrawLiquidity(uint256 _quantity) external onlyHost {
    require(
      _quantity <= liquidity,
      "The quantity cant be greater than liquidity"
    );
    payable(host).transfer(_quantity);
    liquidity -= _quantity;
  }

  // TODO: Random number generator

  function randomGenerator() public view returns(uint256) {
    uint8 _size = 2;
    uint8 _section = 2;
    uint256 _params = uint160(msg.sender) + block.number + block.timestamp;
    bytes memory _encoded = abi.encodePacked(_params);
    uint256 _randomGenerated =  uint256(keccak256(_encoded));
    return (_randomGenerated % (1 * 10 ** (_section + _size))) / (1 * 10 ** _section);
  }

  // Fees Calculations
  function _calculatePercent(uint256 _value, uint16 _percent) internal pure returns(uint256) {
    return (_value * _percent) / 100;
  }

  function calculateHostFee(uint256 _value) public pure returns(uint256) {
    return _calculatePercent(_value, HOST_FEE);
  }

  function calculateLiquidityFee(uint256 _value) public pure returns(uint256) {
    return _calculatePercent(_value, LIQUIDITY_FEE);
  }

  function getTotalWithFeeDiscounts(uint256 _value) public pure returns(uint256) {
    return _value - (calculateHostFee(_value) + calculateLiquidityFee(_value));
  }

  // Fee pay function

  function _feePay(uint256 _value) internal {
    payable(host).transfer(calculateHostFee(_value));
    liquidity += calculateLiquidityFee(_value);
  }

    // Hunterz Functions
  function registerHunter(uint256 _hunterId) external {
    // TODO: Connect with hunter contract!
    require(
      !existentHunterz[_hunterId],
      "Hunter already registered!"
    );
    Hunter memory newHunter = Hunter(msg.sender, 0, 0, 0);
    hunterz[_hunterId] = newHunter;
    existentHunterz[_hunterId] = true;
  }

  // Threats Functions
  function registerThreat(uint256 _threatId) payable external {
    // TODO: Connect with threat contract!
    require(
      !existentThreats[_threatId],
      "Threat already registered!"
    );
    require(
      msg.value >= MIN_BOUNTY,
      "The bounty is insignificant"
    );
    uint256 totalBounty = getTotalWithFeeDiscounts(msg.value);
    _feePay(msg.value);
    Threat memory newThreat = Threat(msg.sender, totalBounty, 0, true);
    threats[_threatId] = newThreat;
    existentThreats[_threatId] = true;
    threatsAlive += 1;
    threatsCount += 1;
  }

  function calculateThreatBurnValue(uint256 _threatId) public view returns(uint256) {
    Threat memory _threat = threats[_threatId];
    uint8 _burnPercent = uint8(BASE_BURN_THREAT_PERCENT + (_threat.totalWins * BURN_PERCENT_PER_WIN));
    if (_burnPercent > 100) {
      return _threat.bounty;
    } else {
      uint256 _bountyToPay = _calculatePercent(_threat.bounty, _burnPercent);
      return _bountyToPay;
    }
  }

  function burnThreat(uint256 _threatId) external onlyThreatOwner(_threatId) activeThreat(_threatId) {
    Threat storage _threat = threats[_threatId];
    uint256 _bountyToPay = calculateThreatBurnValue(_threatId);
    payable(_threat.owner).transfer(_bountyToPay);
    liquidity += (_threat.bounty - _bountyToPay);
    _threat.alive = false;
    threatsAlive -= 1;
  }

  // Strike functions

  function openBountyStrike(uint256 _threatId) external onlyThreatOwner(_threatId) activeThreat(_threatId) {
    Strike memory _newStrike = Strike({
      totalPledge: 0,
      threatId: _threatId,
      status: StrikeStatus.OPEN,
      bounty: threats[_threatId].bounty,
      winnerCovenantId: 0
    });
    blockedThreats[_threatId] = true;
    strikes.push(_newStrike);
  }

  function getHunterActiveCovenant(uint256 _hunterId) external view returns(Covenant memory) {
    require(
      blockedHunterz[_hunterId],
      "The hunter is not in an active covenant now"
    );
    uint256 _activeCovenantIndex = hunterzActiveCovenant[_hunterId];
    return covenants[_activeCovenantIndex];
  }

  function _getPledgeTicketPrice(uint256 _bounty) internal pure returns(uint256) {
    return _calculatePercent(_bounty, PLEDGE_TICKET_PERCENT);
  }

  function _getMaxPledge(uint256 _bounty) internal pure returns(uint256) {
    return _calculatePercent(_bounty, PLEDGE_TICKET_PERCENT * MAX_TICKETS_BY_COVENANT);
  }

  function getStrikeTicketPrice(uint256 _strikeIndex) external view returns(uint256) {
    Strike memory _currentStrike = strikes[_strikeIndex];
    return _getPledgeTicketPrice(_currentStrike.bounty);
  }

  function _getOpenStrikeForPledge(uint256 _strikeIndex) internal openStrike(_strikeIndex) returns(Strike storage) {
    Strike storage _currentStrike = strikes[_strikeIndex];
    require(
      msg.value >= _getPledgeTicketPrice(_currentStrike.bounty),
      string("The pledge is insufficient for one ticket")
    );
    return _currentStrike;
  }

  // Covenant Functions

  function registerCovenantForStrike(uint256 _hunterId, uint256 _strikeIndex) external payable onlyHunterOwner(_hunterId) activeHunter(_hunterId) {
    Strike storage _currentStrike = _getOpenStrikeForPledge(_strikeIndex);
    require(
      msg.value <= _getMaxPledge(_currentStrike.bounty),
      "The pledge exceeds the max value"
    );
    Hunter storage _currentHunter = hunterz[_hunterId];
    Covenant memory _newCovenant = Covenant({
      strikeIndex: _strikeIndex,
      leader: msg.sender,
      pledge: msg.value,
      open: true
    });
    covenantsHunterz[covenants.length].push(_hunterId);
    strikeCovenants[_strikeIndex].push(covenants.length);
    hunterzActiveCovenant[_hunterId] = covenants.length;
    covenants.push(_newCovenant);
    _currentStrike.totalPledge += msg.value;
    _currentHunter.totalPledge += msg.value;
    _currentHunter.totalAttempts += 1;
    blockedHunterz[_hunterId] = true;
  }

  function joinToCovenantForStrike (uint256 _hunterId, uint256 _covenantIndex) external payable onlyHunterOwner(_hunterId) activeHunter(_hunterId) {
    Covenant storage _currentCovenant = covenants[_covenantIndex];
    require(
      _currentCovenant.open,
      "The covenant is closed"
    );
    Strike storage _currentStrike = _getOpenStrikeForPledge(_currentCovenant.strikeIndex);
    require(
      (msg.value + _currentCovenant.pledge) <= _getMaxPledge(_currentStrike.bounty),
      "The pledge exceeds the max value"
    );
    _currentCovenant.pledge += msg.value;
    covenantsHunterz[_covenantIndex].push(_hunterId);
    _currentStrike.totalPledge += msg.value;
    blockedHunterz[_hunterId] = true;
    hunterzActiveCovenant[_hunterId] = _covenantIndex;
  }

  function closeCovenant (uint256 _covenantIndex) external {
    Covenant storage _currentCovenant = covenants[_covenantIndex];
    require(
      _currentCovenant.open,
      "The covenant is closed"
    );
    require(
      _currentCovenant.leader == msg.sender,
      "Just the covenant leader can close it!"
    );
    _currentCovenant.open = false;
  }

  function getStrikeCovenantsCount (uint256 _strikeIndex) external view returns(uint256) {
    return strikeCovenants[_strikeIndex].length;
  }

  // Strike Resolution functions
  
  function _covenantWinStrike(Strike storage _strike, uint256 _covenantId) internal {
    uint256 _bounty = _strike.bounty;
    uint256 _totalPledge = _strike.totalPledge;
    uint256[] memory _hunterzIds = strikeCovenants[_covenantId];
    uint256 _totalHunterz = _hunterzIds.length;
    /**
    * Se transfiere la recompensa con fee a los participantes
    **/
    uint256 _bountyPerHunter = getTotalWithFeeDiscounts(_bounty) / _totalHunterz;
    _feePay(_bounty);
    for (uint i = 0; i < _totalHunterz; i++) {
      uint256 _hunterId = _hunterzIds[i];
      address hunterOwner = hunterz[_hunterId].owner;
      payable(hunterOwner).transfer(_bountyPerHunter);
      blockedHunterz[_hunterId] = false;
      hunterz[_hunterId].totalWins += 1;
    }
    
    /**
    * Se transfiere al dueño de la amenaza el porcentaje de perdida del total de pledge
    */
    uint256 _threatId = _strike.threatId;
    Threat storage _threat = threats[_threatId];
    uint256 _threatLostRewards = _calculatePercent(_totalPledge, THREAT_LOST_PAY_PLEDGE_PERCENT);
    payable(_threat.owner).transfer(_threatLostRewards);
    _threat.alive = false;
    _totalPledge -= _threatLostRewards;

    /**
    * Se transfiere el resto a la liquidez del contrato
    */
    liquidity += _totalPledge;
    _strike.status = StrikeStatus.HUNTERZ;
  }

  function _threatWinStrike(Strike storage _strike, uint256[] memory _strikeCovenantsIds) internal {
    uint256 _totalPledge = _strike.totalPledge;

    /**
    * Se desbloquean los hunterz de los covenants participantes
    */

    for (uint i=0; i < _strikeCovenantsIds.length; i++) {
      uint256 _covenantId = _strikeCovenantsIds[i];
      Covenant storage _covenant = covenants[_covenantId];
      _covenant.open = false;
      uint256[] memory _hunterzIds = covenantsHunterz[_covenantId];
      for (uint j=0; i < _hunterzIds.length; i++) {
        uint256 _hunterId = _hunterzIds[j];
        blockedHunterz[_hunterId] = false;
      }
    }

    /**
    * Se desbloquea la amenaza, se cobran impuestos
    * y se suma el pledge a la recompensa
    */
    uint256 _threatId = _strike.threatId;
    blockedThreats[_threatId] = false;
    Threat storage _threat = threats[_threatId];

    _totalPledge = getTotalWithFeeDiscounts(_totalPledge);
    _feePay(_totalPledge);

    /**
    * Se agrega un tope de hasta duplicar la recompensa
    * Es decir, solo puedes duplicar la recompensa cada strike
    */

    uint256 _tempNewThreatBounty = _threat.bounty + _totalPledge;
    uint256 _doubleBounty = _threat.bounty * 2;

    if (_tempNewThreatBounty > _doubleBounty) {
      _threat.bounty = _doubleBounty;
      uint256 _toLiquidity = _tempNewThreatBounty - _doubleBounty;
      liquidity += _toLiquidity;
    } else {
      _threat.bounty = _tempNewThreatBounty;
    }

    _strike.status = StrikeStatus.THREAT;
  }

  function strikeResolution(uint256 _strikeIndex) external returns(Strike memory) {
    /**
    * Por ahora está al 50/50, hay que crear el sistema
    * El algoritmo aún está rancio
    */
    Strike storage _strike = strikes[_strikeIndex];
    uint256 _randomInt = randomGenerator();
    uint256[] memory _strikeCovenantsIds = strikeCovenants[_strikeIndex];

    if (_randomInt > 50) {
      _threatWinStrike(_strike, _strikeCovenantsIds);
    } else {
      uint256 _totalCovenants = _strikeCovenantsIds.length;
      // Cierra todos los covenants!
      for(uint i = 0; i < _totalCovenants; i++) {
        uint256 _covenantIdForClose = _strikeCovenantsIds[i];
        covenants[_covenantIdForClose].open = false;
      }
      uint256 _covenantId = strikeCovenants[_strikeIndex][_randomInt % _totalCovenants];
      _covenantWinStrike(_strike, _covenantId);
    }
    return _strike;
  }
}