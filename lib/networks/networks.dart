var networkInfo = {
  "bitcoinNetworkInfo": {
    'name': 'Bitcoin Protocol',
    'displayName': 'Bitcoin',
    "native": true,
    'chainId': 0,
    'ticker': 'BITCOIN',
    'description': 'The first blockchain network',
    'derivationPath': "m/84'/0'/0'/0/0",
    'isTestnet': false,
    'logoUrl': 'https://Beepo.blob.core.windows.net/logos/Bitcoin.png',
    'nameoncoinmarketcap': 'bitcoin',
  },

  // solanaNetworkInfo: {
  //  'name': 'Solana Mainnet',
  //   'displayName': 'Solana',
  //   'chainId': 501,
  //   'ticker': 'SOL',
  //   'description': 'The first non-EVM based blockchain network aside bitcoin',
  //   'derivationPath': "m/44'/501'/0'/0",
  //   'isTestnet': false,
  //   'logoUrl': 'https://Beepo.blob.core.windows.net/logos/Solana.png',
  //   'nameoncoinmarketcap': 'Solana',
  // },

  'networksInfo': {
    11155111: {
      'name': 'Ethereum Mainnet',
      'displayName': 'Ethereum',
      'chainId': 11155111,
      'ticker': 'ETH',
      "nativeTicker": "ETH",
      "native": true,
      'description': 'The first EVM based blockchain network',
      'derivationPath': "m/44'/60'/0'/0",
      'isTestnet': false,
      'logoUrl': 'https://Beepo.blob.core.windows.net/logos/Ethereum.png',
      'nameoncoinmarketcap': 'ethereum',
    },
    'usdt': {
      'name': 'Ethereum Mainnet',
      'displayName': 'USDT',
      'chainId': 1,
      "address": '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      'ticker': 'USDT',
      'nativeTicker': 'ETH',
      "rpc": {
        'https': 'https://eth-pokt.nodies.app',
        'testnet': 'https://eth-pokt.nodies.app',
        //'testnet': 'https://goerli.infura.io/v3/5fd05c9976d44bb7a6e849317e9ad9c0',
        'wss': '',
      },
      'description': 'The first EVM based blockchain network',
      'derivationPath': "m/44'/60'/0'/0",
      'isTestnet': false,
      'logoUrl':
          'https://res.cloudinary.com/dwruvre6o/image/upload/v1697100571/usdt_jiebah.png',
      'nameoncoinmarketcap': 'tether',
    },
    // 'MTK': {
    //   'name': 'My Token ETH',
    //   'displayName': 'MTK',
    //   'chainId': 11155111,
    //   "address": '0x7a8609Ae329C2fA2AD62cEe6a35dA7515Bd87D38',
    //   'ticker': 'MTK',
    //   'nativeTicker': 'ETH',
    //   "rpc": {
    //     'https': 'https://eth-pokt.nodies.app',
    //     'testnet': 'https://eth-sepolia.g.alchemy.com/v2/HDQnQBbyr2HtgKSym1OqrbGED_H7Ev2N',
    //     //'testnet': 'https://goerli.infura.io/v3/5fd05c9976d44bb7a6e849317e9ad9c0',
    //     'wss': '',
    //   },
    //   'description': 'The first EVM based blockchain network',
    //   'derivationPath': "m/44'/60'/0'/0",
    //   'isTestnet': false,
    //   'logoUrl': 'https://res.cloudinary.com/dwruvre6o/image/upload/v1697100571/usdt_jiebah.png',
    //   'nameoncoinmarketcap': 'tether',
    // },

    56: {
      'name': 'Binance Smartchain Mainnet',
      'displayName': 'Binance Smartchain',
      'chainId': 97,
      "address": '0x55d398326f99059fF775485246999027B3197955',
      'ticker': 'BNB',
      'nativeTicker': 'BNB',
      "native": true,
      'description':
          'The centralized  EVM based smart blockchain network with low transaction fees',
      'derivationPath': "m/44'/60'/0'/0",
      'isTestNet': false,
      'logoUrl': 'https://Beepo.blob.core.windows.net/logos/Smartchain.png',
      'nameoncoinmarketcap': 'binancecoin',
    },

    666888: {
      'name': 'HeLa Testnet',
      'displayName': 'HeLa',
      'chainId': 666888,
      "native": true,
      'ticker': 'HLUSD',
      'nativeTicker': 'HLUSD',
      'description': 'This is the Polygon matic description',
      'derivationPath': "m/44'/60'/0'/0",
      'isTestNet': false,
      'logoUrl':
          'https://res.cloudinary.com/dwruvre6o/image/upload/v1704047296/whatishela_g3574d.png',
      'nameoncoinmarketcap': 'matic-network',
    },
    137: {
      'name': 'Polygon Mainnet',
      'displayName': 'Polygon',
      'chainId': 137,
      "native": true,
      'ticker': 'MATIC',
      'nativeTicker': 'MATIC',
      'description': 'This is the Polygon matic description',
      'derivationPath': "m/44'/60'/0'/0",
      'isTestNet': false,
      'logoUrl': 'https://Beepo.blob.core.windows.net/logos/Polygon.png',
      'nameoncoinmarketcap': 'matic-network',
    },
    42220: {
      'name': 'Celo Mainnet',
      'displayName': 'Celo',
      'chainId': 42220,
      "native": true,
      'ticker': 'CELO',
      'nativeTicker': 'CELO',
      'description': 'The Celo network',
      'derivationPath': "m/44'/52752'/0'/0",
      'isTestNet': false,
      'logoUrl': 'https://Beepo.blob.core.windows.net/logos/Celo.png',
      'nameoncoinmarketcap': 'celo',
    },
    256256: {
      'name': 'Caduceus Mainnet',
      'displayName': 'Caduceus',
      'chainId': 256256,
      "native": true,
      'ticker': 'CMP',
      'nativeTicker': 'CMP',
      'description': 'The Caduceus network',
      'derivationPath': "m/44'/60'/0'/0",
      'isTestNet': false,
      'logoUrl': 'https://Beepo.blob.core.windows.net/logos/Caduceus.png',
      'nameoncoinmarketcap': 'caduceus',
    },
    // 32520: {
    //   'name': 'Bitgert Mainnet',
    //   'displayName': 'Bitgert',
    //   'chainId': 32520,
    //   'ticker': 'Brise',
    //   'description': 'The Bitgert network',
    //   'derivationPath': "m/44'/60'/0'/0",
    //   'isTestNet': false,
    //   'logoUrl': 'https://Beepoassets.s3.amazonaws.com/bitgert.jpeg',
    //   'nameoncoinmarketcap': 'Bitgert',
    // },
    'bitgert': {
      'name': 'Bitgert Mainnet',
      'displayName': 'Bitgert',
      'chainId': 32520,
      'ticker': 'BRISE',
      'nativeTicker': 'BNB',
      "rpc": {
        'https': 'https://bsc-dataseed.binance.org/',
        'testnet': 'https://bsc-dataseed.binance.org/',
        //'testnet': 'https://data-seed-prebsc-1-s1.binance.org:8545/',
        'wss': ""
      },
      'description': 'The Bitgert network',
      'derivationPath': "m/44'/60'/0'/0",
      "address": '0x8FFf93E810a2eDaaFc326eDEE51071DA9d398E83',
      'isTestNet': false,
      'logoUrl': 'https://Beepoassets.s3.amazonaws.com/bitgert.jpeg',
      'nameoncoinmarketcap': 'bitrise-token',
    },
    "Beepo": {
      'name': 'Beepo',
      'displayName': 'Beepo',
      "address": '0x87c6ccc98f62d2aa4bd072610b8064991bf81d83',
      'ticker': 'BEEP',
      'nativeTicker': 'BNB',
      'chainId': 56,
      "rpc": {
        'https': 'https://bsc-dataseed.binance.org/',
        'testnet': 'https://bsc-dataseed.binance.org/',
        //'testnet': 'https://data-seed-prebsc-1-s1.binance.org:8545/',
        'wss': ""
      },
      'description': 'The Beepo network',
      'derivationPath': "m/44'/60'/0'/0",
      'isTestNet': false,
      'logoUrl':
          'https://res.cloudinary.com/dwruvre6o/image/upload/v1701096455/icon_cownk2.png',
      'nameoncoinmarketcap': 'tether',
    },
  },

  'rpcUrls': {
    11155111: {
      'https': 'https://eth-pokt.nodies.app',
      'testnet':
          'https://eth-sepolia.g.alchemy.com/v2/HDQnQBbyr2HtgKSym1OqrbGED_H7Ev2N',
      'wss': '',
    },
    5: {
      'https': 'https://goerli.infura.io/v3/5fd05c9976d44bb7a6e849317e9ad9c0',
      'testnet': 'https://goerli.infura.io/v3/5fd05c9976d44bb7a6e849317e9ad9c0',
      'wss': '',
    },
    666888: {
      'https': 'https://testnet-rpc.helachain.com',
      'testnet': 'https://testnet-rpc.helachain.com',
      'wss': '',
    },
    56: {
      'https': 'https://bsc-dataseed.binance.org/',
      'testnet': 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      'wss': ""
    },
    42220: {
      'https': "https://forno.celo.org",
      'testnet': "https://alfajores-forno.celo-testnet.org",
      'wss': "wss://forno.celo.org/ws"
    },
    137: {
      'https': "https://polygon-rpc.com",
      'testnet': "https://rpc-mumbai.maticvigil.com",
      'wss': ""
    },
    256256: {
      'https': "https://mainnet.block.caduceus.foundation",
      'testnet': "https://galaxy.block.caduceus.foundation",
      'wss': "",
    },
    32520: {
      'https': "https://rpc.icecreamswap.com",
      'testnet': "https://rpc.icecreamswap.com",
      'wss': "",
    }
  },

  'contractAddresses': {
    5: {'contractAddress': "0x627118a4fB747016911e5cDA82e2E77C531e8206"},
    1: {
      'contractAddress': "0x2170ed0880ac9a755fd29b2688956bd959f933f8",
    },
    56: {
      'contractAddress': "0x242a1ff6ee06f2131b7924cacb74c7f9e3a5edc9",
    },
    137: {'contractAddress': "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619"},
    42220: {'contractAddress': "0xc03f9c16aebad87379c0036390317a1ebde59081"},
    256256: {'contractAddress': "0x07686C0BA221f2427BB95B88ee8A94E784022ed0"}
  },

  'supportedNetworkIds': [
    1,
    5,
    56,
    42220,
    137,
    256256,
    32520,
    "bitcoin",
    "Beepo"
  ],

  'supportedNetworkNames': [
    'bitcoin',
    'bitgert',
    'ethereum',
    'smartchainMainnet',
    'smartchainTestnet',
    'celo',
    'polygon',
    'caduceus',
    'Beepo'
  ],

  'networkNameMap': {
    'ethereumMainnet': 1,
    'smartchainMainnet': 56,
    'celo': 42220,
    'celoTestnet': 4220,
    'polygon': 137,
    'caduceusMainnet': 256256,
    'bitgert': 32520
  },

  'networkNames': [
    'ethereum',
    'bsc',
    'bscTestnet',
    'matic',
    'mumbai',
    'sepolia',
    'goerli'
  ],

  'explorerUrls': {
    1: "https://etherscan.io",
    5: "https://goerli.etherscan.io",
    56: "https://bscscan.com",
    42220: "https://explorer.celo.org/mainnet",
    137: "https://polygonscan.com",
    256256: "https://mainnet.scan.caduceus.foundation",
    32520: "https://explorer.bitgert.com",
  },
};




// final Map<String, dynamic> networkInfo = {
//   'networksInfo': {
//     'Ethereum': {
//       'displayName': 'Ethereum',
//       'logoUrl': 'assets/images/eth_logo.png',
//       'ticker': 'ETH',
//       'nativeTicker': 'ETH',
//       'address': '', // Empty for native token
//       'chainId': '1',
//       'network': 'mainnet', // This will be used by Alchemy
//       'isNative': true,
//     },
//     'USDT': {
//       'displayName': 'Tether USD',
//       'logoUrl': 'assets/images/usdt_logo.png',
//       'ticker': 'USDT',
//       'nativeTicker': 'USDT',
//       'address': '0xdac17f958d2ee523a2206206994597c13d831ec7', // USDT contract address
//       'chainId': '1',
//       'network': 'mainnet',
//       'isNative': false,
//     },
//     'Polygon': {
//       'displayName': 'Polygon',
//       'logoUrl': 'assets/images/matic_logo.png',
//       'ticker': 'MATIC',
//       'nativeTicker': 'MATIC',
//       'address': '',
//       'chainId': '137',
//       'network': 'polygon-mainnet', // Polygon network in Alchemy
//       'isNative': true,
//     },
//     'Bitcoin': {
//       'displayName': 'Bitcoin',
//       'logoUrl': 'assets/images/btc_logo.png',
//       'ticker': 'BTC',
//       'nativeTicker': 'BTC',
//       'chainId': null, // Bitcoin doesn't use chainId
//       'network': 'bitcoin',
//       'isNative': true,
//     },
//     // Add more networks/tokens as needed
//   }
// };