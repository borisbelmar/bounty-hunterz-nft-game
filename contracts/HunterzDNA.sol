// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
  * TODO: Aún no implementado!
 */

contract HunterzDNA {
  string[] private _headTypes = [
    "Head01",
    "Head02",
    "Head03",
    "Head04",
    "Head05"
  ];

  string[][] private _headTypesSvgPaths = [
    [
      "M306 177.796C306 246.25 256.889 349 181.633 349C106.378 349 67 235.989 67 167.534C67 99.08 133.955 66 209.21 66C284.466 66 306 109.341 306 177.796Z",
      "M128.5 153.5C114.5 179 122.157 206.5 101.5 206.5C80.8435 206.5 81 170.765 81 149.029C81 127.292 133.343 91 154 91C174.657 91 142.5 128 128.5 153.5Z"
    ],
    [
      "M306 177.796C306 246.25 262.256 331 187 331C111.744 331 67 235.989 67 167.534C67 99.08 133.955 66 209.21 66C284.466 66 306 109.341 306 177.796Z",
      "M125 149.029C111 174.529 116.157 185.029 95.5 185.029C74.8435 185.029 77.5 166.293 77.5 144.557C77.5 122.821 115.343 93.0286 136 93.0286C156.657 93.0286 139 123.529 125 149.029Z"
    ],
    [
      "M306 177.796C306 246.25 262.256 331 187 331C111.744 331 103.562 253 95.5 177.796C88.5 112.5 94.5 66 209.21 66C284.466 66 306 109.341 306 177.796Z",
      "M154.232 128.303C129.358 143.387 128.574 155.058 110.685 144.73C92.7957 134.402 104.464 119.505 115.332 100.681C126.2 81.8564 173.87 74.9773 191.759 85.3056C209.648 95.6339 179.107 113.219 154.232 128.303Z"
    ],
    [
      "M302 182C302 250.454 260.756 351 185.5 351C110.244 351 107.5 274 59.5 182C29.1233 123.778 94.5 66 209.21 66C253 66 302 113.546 302 182Z",
      "M88.2358 153.921C76.7304 171.431 79.8339 179.263 65.0032 178.086C50.1725 176.908 53.148 163.608 54.3873 148.002C55.6266 132.396 84.4956 113.164 99.3263 114.342C114.157 115.52 99.7412 136.411 88.2358 153.921Z"
    ],
    [
      "M325.5 143.5C325.5 211.954 332.256 344.5 257 344.5C181.744 344.5 109 318 61 226C30.6233 167.778 94.5 66 209.21 66C253 66 325.5 75.0457 325.5 143.5Z",
      "M94.069 182.341C87.5029 202.237 92.5333 208.996 77.9052 211.708C63.2771 214.42 62.6984 200.804 59.8444 185.411C56.9905 170.018 79.8779 143.952 94.506 141.24C109.134 138.527 100.635 162.445 94.069 182.341Z"
    ]
  ];

  string[] private _bodyTypes = [
    "Body01",
    "Body02",
    "Body03",
    "Body04",
    "Body05"
  ];

  string[][] private _bodyTypesSvgPaths = [
    [
      "M300 537.051C300 635.859 231.235 661 156.07 661C80.9041 661 56 625.808 56 527C56 428.192 102.237 295 177.403 295C252.568 295 300 438.243 300 537.051Z",
      "M251 361.923C251 382.711 215.524 388 176.746 388C137.968 388 105 376.561 105 355.773C105 334.986 148.974 311 187.752 311C226.53 311 251 341.136 251 361.923Z"
    ],
    [
      "M310.5 499C310.5 597.808 231.235 661 156.07 661C80.9042 661 96.5 582.808 96.5 484C96.5 385.192 102.237 295 177.403 295C252.568 295 310.5 400.192 310.5 499Z",
      "M247.205 336.188C252.585 356.267 219.687 370.558 182.231 380.595C144.774 390.631 109.968 388.114 104.588 368.035C99.208 347.956 135.476 313.406 172.932 303.37C210.389 293.333 241.825 316.109 247.205 336.188Z"
    ],
    [
      "M323.5 499C323.5 597.808 244.235 661 169.07 661C93.9041 661 39 564.308 39 465.5C39 366.692 115.237 295 190.403 295C265.568 295 323.5 400.192 323.5 499Z",
      "M236.23 325.599C240.78 342.581 212.958 354.667 181.28 363.155C149.602 371.643 121.435 369.514 116.885 352.533C112.335 335.552 141.739 306.332 173.416 297.844C205.094 289.356 231.68 308.618 236.23 325.599Z"
    ],
    [
      "M266 499C266 597.808 218.358 661 173.179 661C128 661 95 564.308 95 465.5C95 366.692 140.823 295 186.001 295C231.18 295 266 400.192 266 499Z",
      "M224.053 330.599C228.603 347.581 208.432 357.616 185.118 363.863C161.804 370.11 140.435 366.16 135.885 349.179C131.335 332.198 151.567 305.436 174.881 299.189C198.195 292.942 219.503 313.618 224.053 330.599Z"
    ],
    [
      "M283 447C283 571 218.358 661 173.179 661C128 661 64 545.808 64 447C64 348.192 126 295 186.001 295C253.5 295 264 347 283 447Z",
      "M227.053 336.599C231.603 353.581 211.432 363.616 188.118 369.863C164.804 376.11 143.435 372.16 138.885 355.179C134.335 338.198 154.567 311.436 177.881 305.189C201.195 298.942 222.503 319.618 227.053 336.599Z"
    ]
  ];

  string[] private _skinColors = [
    "#ff7979",
    "#badc58",
    "#ffbe76",
    "#7ed6df"
  ];

  string[] private _eyesTypes = [
    "Eyes01",
    "Eyes02",
    "Eyes03",
    "Eyes04",
    "Eyes05"
  ];

  string[] private _eyesColors = [
    "#161E26",
    "#2c2c54",
    "#cc8e35",
    "#b33939",
    "#218c74"
  ];

  string[][] private _eyesTypesSvgPaths = [
    [
      "M210 213.053C210 228.375 200.625 232 182.465 232C164.306 232 156 228.375 156 213.053C156 197.73 169.919 204.481 188.079 204.481C206.239 204.481 210 197.73 210 213.053Z",
      "M287.999 212.754C287.999 227.621 282.679 228 264.674 228C246.669 228 244 227.621 244 212.754C244 197.887 252.5 204.437 270.505 204.437C288.51 204.437 287.999 197.887 287.999 212.754Z",
      "M288 186.73C288 205.089 283.15 217 264.916 217C246.682 217 237 197.522 237 179.162C237 160.802 239.166 157 257.4 157C275.634 157 288 168.37 288 186.73Z",
      "M212 186.481C212 204.869 201.048 226 182.933 226C164.818 226 156 207.575 156 189.188C156 170.801 175.218 154 193.333 154C211.448 154 212 168.094 212 186.481Z",
      "M175.986 181.387C175.322 186.6 175.271 189.784 170.514 190.087C165.756 190.39 164.872 185.521 164.567 180.726C164.262 175.931 169.135 171.487 173.892 171.184C178.649 170.881 176.649 176.174 175.986 181.387Z"
    ],
    [
      "M212.5 204.481C212.5 219.804 201.16 234 183 234C164.84 234 155 221.823 155 206.5C155 191.177 169.919 204.481 188.079 204.481C206.239 204.481 212.5 189.159 212.5 204.481Z",
      "M292.5 208.5C292.5 223.367 282.505 231.5 264.5 231.5C246.495 231.5 234 219.304 234 204.437C234 189.57 250.495 202.5 268.5 202.5C286.505 202.5 292.5 193.633 292.5 208.5Z",
      "M288 186.73C288 205.089 283.15 217 264.916 217C246.682 217 236.5 205.089 236.5 186.73C236.5 168.37 240.766 169.5 259 169.5C277.234 169.5 288 168.37 288 186.73Z",
      "M212 186.481C212 204.869 201.048 226 182.933 226C164.818 226 156 207.575 156 189.188C156 170.801 171.885 167.5 190 167.5C208.115 167.5 212 168.094 212 186.481Z",
      "M172.124 186.902C169.829 191.629 168.763 194.631 164.158 193.397C159.554 192.163 160.272 187.267 161.516 182.626C162.759 177.985 168.797 175.332 173.402 176.565C178.006 177.799 174.419 182.175 172.124 186.902Z"
    ],
    [
      "M213 209.997C213 236.991 198.818 243 180.5 243C162.182 243 155 240.547 155 213.553C155 186.559 170.049 209.997 188.367 209.997C206.685 209.997 213 183.003 213 209.997Z",
      "M291.5 205.685C291.5 230.454 277.851 230.5 260 230.5C242.149 230.5 234 233.682 234 208.912C234 184.143 250.354 205.685 268.205 205.685C286.056 205.685 291.5 180.916 291.5 205.685Z",
      "M287.5 178C296.457 194.5 283.15 214 264.916 214C246.682 214 237 209.36 237 191C237 172.64 242.766 178 261 178C279.234 178 278 160.5 287.5 178Z",
      "M212 178.712C212 200.714 198.897 226 177.224 226C155.551 226 145 193.002 145 171C145 148.998 172.327 166.5 194 166.5C215.673 166.5 212 156.711 212 178.712Z",
      "M163.124 182.902C160.829 187.63 162.604 189.234 158 188C153.396 186.766 151.256 181.141 152.5 176.5C153.744 171.859 157.396 171.766 162 173C166.604 174.234 165.419 178.175 163.124 182.902Z"
    ],
    [
      "M193 210.997C193 222.5 177.818 232.5 159.5 232.5C141.182 232.5 135 227 135 214.553C135 187.559 150.049 210.997 168.367 210.997C186.685 210.997 193 184.003 193 210.997Z",
      "M288 199.5C288 216 279.851 222 262 222C244.149 222 234 225 234 208.912C234 192.825 255.705 199.5 265.5 199.5C275.295 199.5 288 174.731 288 199.5Z",
      "M292 159C294.5 179 283.15 214 264.916 214C246.682 214 239.5 207 235.5 192.5C231.5 178 237.578 159.89 253 153.5C267.099 147.658 289.53 139.241 292 159Z",
      "M196 178.712C196 200.714 182.897 226 161.224 226C139.551 226 123 200.714 123 178.712C123 156.71 127.327 148.5 149 148.5C170.673 148.5 196 156.71 196 178.712Z",
      "M142.13 175.043C139.835 179.77 141.611 181.374 137.007 180.14C132.402 178.907 130.263 173.282 131.507 168.641C132.75 163.999 136.402 163.907 141.007 165.141C145.611 166.374 144.426 170.316 142.13 175.043Z"
    ],
    [
      "M193 210.997C193 222.5 177.818 232.5 159.5 232.5C141.182 232.5 119 210.947 119 198.5C119 171.506 150.049 210.997 168.367 210.997C186.685 210.997 193 184.003 193 210.997Z",
      "M291 192.627C299.285 206.896 284.851 224.5 267 224.5C249.149 224.5 238 221 238 204.913C238 188.825 259.705 195.5 269.5 195.5C279.295 195.5 282 177.127 291 192.627Z",
      "M283.5 181.5C286 201.5 283.15 214 264.916 214C246.682 214 239.5 207 235.5 192.5C231.5 178 236.078 178.39 251.5 172C265.599 166.158 281.03 161.741 283.5 181.5Z",
      "M196 178.712C196 200.714 182.897 226 161.224 226C139.551 226 123 200.714 123 178.712C123 156.71 118.327 130 140 130C161.673 130 196 156.71 196 178.712Z",
      "M139.137 152.543C136.842 157.27 135.111 170.234 130.507 169C125.902 167.766 127.27 150.782 128.513 146.141C129.757 141.499 133.409 141.407 138.013 142.641C142.618 143.874 141.432 147.816 139.137 152.543Z"
    ]
  ];

  string[] private _mouthTypes = [
    "Mouth01",
    "Mouth02",
    "Mouth03",
    "Mouth04",
    "Mouth05"
  ];

  string[][] private _mouthTypesSvgPaths = [
    [
      "M234.94 282.142C233.339 286.056 214.727 294.204 202 289C187.495 284.668 198.49 253.156 199.5 249C203.323 243.024 207.273 257.296 220 262.5C232.727 267.704 237.021 277.053 234.94 282.142Z",
      ""
    ],
    [
      "M234.94 282.142C233.34 286.056 223.087 277.295 210.36 272.091C195.856 267.759 187.843 267.453 188.853 263.296C192.676 257.32 199.154 263.168 211.881 268.372C224.608 273.576 237.021 277.053 234.94 282.142Z",
      ""
    ],
    [
      "M266.457 276.387C262.742 285.471 259.904 273.708 252.869 270.831C243.86 270.858 237.591 275.187 240.979 265.969C247.761 251.248 249.362 259.325 256.397 262.201C263.433 265.078 271.286 264.578 266.457 276.387Z",
      "M355 266.771C355 276.585 327.995 266.771 299 266.771C267.231 270.205 251.346 276.585 250 266.771C252.692 250.578 270.005 257.447 299 257.447C327.995 257.447 355 254.013 355 266.771Z"
    ],
    [
      "M238.534 253.912C231.245 271.738 213.535 287.807 206.5 284.931C196.24 288.018 199.538 271.871 206.5 253.912C219.18 224.767 206.465 268.123 213.5 271C220.535 273.877 248.009 230.739 238.534 253.912Z",
      ""
    ],
    [
      "M247.128 283.536C239.839 301.362 222.13 317.431 215.095 314.554C204.835 317.641 178.132 318.583 185.095 300.624C197.775 271.478 212.059 280.659 219.095 283.536C226.13 286.413 256.604 260.362 247.128 283.536Z",
      ""
    ]
  ];

  string[] private _planetColors = [
    "#B02A00",
    "#be2edd",
    "#4834d4",
    "#eb4d4b",
    "#30336b",
    "#535c68"
  ];

  function _getHeadTypeSvgPath(uint _headTypeIndex, string memory _skinColor) public view returns (string memory) {
    string memory path1 = string(
      abi.encodePacked(
        "<path d='",
        _headTypesSvgPaths[_headTypeIndex][0],
        "' fill='",
        _skinColor,
        "'/>"
      )
    );
    return string(
      abi.encodePacked(
        path1,
        "<path d='",
        _headTypesSvgPaths[_headTypeIndex][1],
        "' fill='white' fill-opacity='0.1'/>"
      )
    );
  }

  function _getBodyTypeSvgPath(uint _bodyTypeIndex, string memory _skinColor) public view returns (string memory) {
    string memory path1 = string(
      abi.encodePacked(
        "<path d='",
        _bodyTypesSvgPaths[_bodyTypeIndex][0],
        "' fill='",
        _skinColor,
        "'/>"
      )
    );
    return string(
      abi.encodePacked(
        "<g clip-path='url(#clip512)'>",
        path1,
        "<path d='",
        _bodyTypesSvgPaths[_bodyTypeIndex][1],
        "' fill='black' fill-opacity='0.05'/>",
        "</g>"
      )
    );
  }

  function _getEyesTypeSvgPath(uint _bodyTypeIndex, string memory _eyesColor) public view returns (string memory) {
    string memory path1 = string(
      abi.encodePacked(
        "<path d='",
        _eyesTypesSvgPaths[_bodyTypeIndex][0],
        "' fill='black' fill-opacity='0.05' />"
      )
    );
    string memory path2 = string(
      abi.encodePacked(
        "<path d='",
        _eyesTypesSvgPaths[_bodyTypeIndex][1],
        "' fill='black' fill-opacity='0.05' />"
      )
    );
    string memory path3 = string(
      abi.encodePacked(
        "<path d='",
        _eyesTypesSvgPaths[_bodyTypeIndex][2],
        "' fill='",
        _eyesColor,
        "' />"
      )
    );
    string memory path4 = string(
      abi.encodePacked(
        "<path d='",
        _eyesTypesSvgPaths[_bodyTypeIndex][3],
        "' fill='",
        _eyesColor,
        "' />"
      )
    );
    return string(
      abi.encodePacked(
        path1,
        path2,
        path3,
        path4,
        "<path d='",
        _eyesTypesSvgPaths[_bodyTypeIndex][4],
        "' fill='white' fill-opacity='0.1'/>"
      )
    );
  }

  function _getMouthTypeSvgPath(uint _mouthTypeIndex) public view returns (string memory) {
    string memory path1 = string(
      abi.encodePacked(
        "<path d='",
        _mouthTypesSvgPaths[_mouthTypeIndex][0],
        "' fill='#161E26'/>"
      )
    );
    return string(
      abi.encodePacked(
        path1,
        "<path d='",
        _mouthTypesSvgPaths[_mouthTypeIndex][1],
        "' fill='#C4C4C4'/>"
      )
    );
  }

  function _getPlanetTypeSvgPath(string memory _planetColor) public pure returns (string memory) {
    string memory _planetCircle = string(
      abi.encodePacked(
        "<circle cx='440' cy='512' r='312' fill='",
        _planetColor,
        "'/>"
      )
    );
    return string(
      abi.encodePacked(
        "<g clip-path='url(#clip512)'>",
        _planetCircle,
        "</g>"
      )
    );
  }

  function deterministicPseudoRandomDNA(uint256 _tokenId, address _minter) public view returns(uint256) {
    uint256 combinedParams = _tokenId + uint160(_minter) + block.timestamp + block.number;
    bytes memory encodedParams = abi.encodePacked(combinedParams);
    bytes32 hashedParams = keccak256(encodedParams);

    return uint256(hashedParams);
  }

  // Get attributes
  uint8 constant ADN_SECTION_SIZE = 2;

  function _getDNASection (uint256 _dna, uint8 _rightDiscard) internal pure returns (uint8) {
    return uint8(
      (_dna % (1 * 10 ** (_rightDiscard + ADN_SECTION_SIZE))) / (1 * 10 ** _rightDiscard)
    );
  }

  function _getItem(string[] memory _items, uint256 _dna, uint8 _section) internal pure returns (string memory) {
    uint8 dnaSection = _getDNASection(_dna, _section);
    return _items[dnaSection % _items.length];
  }

  function getSkinColor(uint256 _dna) public view returns (string memory) {
    return _getItem(_skinColors, _dna, 0);
  }

  function getHeadType(uint _dna) public view returns(string memory) {
    return _getItem(_headTypes, _dna, 1);
  }

  function getHeadSvg(uint _dna) public view returns(string memory) {
    string memory _skinColor = getSkinColor(_dna);
    uint headSection = _getDNASection(_dna, 1);
    return _getHeadTypeSvgPath(headSection % _headTypesSvgPaths.length, _skinColor);
  }

  function getBodySvg(uint _dna) public view returns(string memory) {
    string memory _skinColor = getSkinColor(_dna);
    uint bodySection = _getDNASection(_dna, 2);
    return _getBodyTypeSvgPath(bodySection % _bodyTypesSvgPaths.length, _skinColor);
  }

  function getEyesColor(uint256 _dna) public view returns (string memory) {
    return _getItem(_eyesColors, _dna, 3);
  }

  function getEyesSvg(uint _dna) public view returns(string memory) {
    string memory _eyesColor = getEyesColor(_dna);
    uint eyesSection = _getDNASection(_dna, 4);
    return _getEyesTypeSvgPath(eyesSection % _eyesTypesSvgPaths.length, _eyesColor);
  }

  function getMouthSvg(uint _dna) public view returns(string memory) {
    uint mouthSection = _getDNASection(_dna, 5);
    return _getMouthTypeSvgPath(mouthSection % _mouthTypesSvgPaths.length);
  }

  function getPlanetColor(uint256 _dna) public view returns (string memory) {
    return _getItem(_planetColors, _dna, 6);
  }

  function getPlanetSvg(uint256 _dna) public view returns (string memory) {
    return _getPlanetTypeSvgPath(getPlanetColor(_dna));
  }
}