
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Cache entry with timestamp
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  
  CacheEntry(this.data) : timestamp = DateTime.now();
  
  bool isExpired(Duration maxAge) {
    return DateTime.now().difference(timestamp) > maxAge;
  }
}

// API service with caching
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  final Map<String, CacheEntry<double>> _priceCache = {};
  final Map<String, CacheEntry<Map<String, double>>> _exchangeRateCache = {};
  static const Duration _cacheDuration = Duration(seconds: 60);
  
  // Top 1000 Crypto Symbol-to-ID Map
  static const Map<String, String> _cryptoSymbolToIdMap = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'XRP': 'ripple',
    'USDT': 'tether',
    'BNB': 'binancecoin',
    'SOL': 'solana',
    'USDC': 'usd-coin',
    'STETH': 'staked-ether',
    'DOGE': 'dogecoin',
    'TRX': 'tron',
    'ADA': 'cardano',
    'WSTETH': 'wrapped-steth',
    'HYPE': 'hyperliquid',
    'WBTC': 'wrapped-bitcoin',
    'LINK': 'chainlink',
    'WBETH': 'wrapped-beacon-eth',
    'XLM': 'stellar',
    'SUI': 'sui',
    'WEETH': 'wrapped-eeth',
    'BCH': 'bitcoin-cash',
    'USDE': 'ethena-usde',
    'HBAR': 'hedera-hashgraph',
    'AVAX': 'avalanche-2',
    'WETH': 'weth',
    'LTC': 'litecoin',
    'TON': 'the-open-network',
    'LEO': 'leo-token',
    'USDS': 'usds',
    'SHIB': 'shiba-inu',
    'BSC-USD': 'binance-bridged-usdt-bnb-smart-chain',
    'UNI': 'uniswap',
    'WBT': 'whitebit',
    'CBBTC': 'coinbase-wrapped-btc',
    'DOT': 'polkadot',
    'SUSDE': 'ethena-staked-usde',
    'BGB': 'bitget-token',
    'CRO': 'crypto-com-chain',
    'ENA': 'ethena',
    'PEPE': 'pepe',
    'AAVE': 'aave',
    'XMR': 'monero',
    'MNT': 'mantle',
    'DAI': 'dai',
    'TAO': 'bittensor',
    'ETC': 'ethereum-classic',
    'NEAR': 'near',
    'APT': 'aptos',
    'ONDO': 'ondo-finance',
    'PI': 'pi-network',
    'ICP': 'internet-computer',
    'JITOSOL': 'jito-staked-sol',
    'ARB': 'arbitrum',
    'BUIDL': 'blackrock-usd-institutional-digital-liquidity-fund',
    'KAS': 'kaspa',
    'ALGO': 'algorand',
    'USD1': 'usd1-wlfi',
    'GT': 'gatechain-token',
    'POL': 'polygon-ecosystem-token',
    'VET': 'vechain',
    'ATOM': 'cosmos',
    'RETH': 'rocket-pool-eth',
    'PENGU': 'pudgy-penguins',
    'RENDER': 'render-token',
    'FTN': 'fasttoken',
    'OKB': 'okb',
    'BNSOL': 'binance-staked-sol',
    'SEI': 'sei-network',
    'SUSDS': 'susds',
    'RSETH': 'kelp-dao-restaked-eth',
    'WLD': 'worldcoin-wld',
    'BONK': 'bonk',
    'TRUMP': 'official-trump',
    'FET': 'fetch-ai',
    'JLP': 'jupiter-perpetuals-liquidity-provider-token',
    'FLR': 'flare-networks',
    'IP': 'story-2',
    'FIL': 'filecoin',
    'OSETH': 'stakewise-v3-oseth',
    'KCS': 'kucoin-shares',
    'LSETH': 'liquid-staked-ethereum',
    'USDT0': 'usdt0',
    'SKY': 'sky',
    'QNT': 'quant-network',
    'LBTC': 'lombard-staked-btc',
    'JUP': 'jupiter-exchange-solana',
    'METH': 'mantle-staked-ether',
    'USDTB': 'usdtb',
    'INJ': 'injective-protocol',
    'XDC': 'xdce-crowd-sale',
    'SPX': 'spx6900',
    'NEXO': 'nexo',
    'KHYPE': 'kinetic-staked-hype',
    'USDF': 'falcon-finance',
    'EZETH': 'renzo-restaked-eth',
    'TIA': 'celestia',
    'FDUSD': 'first-digital-usd',
    'STX': 'blockstack',
    'OP': 'optimism',
    'XAUT': 'tether-gold',
    'LDO': 'lido-dao',
    'PUMP': 'pump-fun',
    'SOLVBTC': 'solv-btc',
    'PYUSD': 'paypal-usd',
    'CRV': 'curve-dao-token',
    'AERO': 'aerodrome-finance',
    'WBNB': 'wbnb',
    'JUPSOL': 'jupiter-staked-sol',
    'IMX': 'immutable-x',
    'CLBTC': 'clbtc',
    'XTZ': 'tezos',
    'PENDLE': 'pendle',
    'KAIA': 'kaia',
    'WIF': 'dogwifcoin',
    'ENS': 'ethereum-name-service',
    'MSOL': 'msol',
    'CGETH.HASHKEY': 'cgeth-hashkey-cloud',
    'THETA': 'theta-token',
    'A': 'vaulta',
    'IOTA': 'iota',
    'JASMY': 'jasmycoin',
    'VIRTUAL': 'virtual-protocol',
    'EETH': 'ether-fi-staked-eth',
    'GALA': 'gala',
    'CMETH': 'mantle-restaked-eth',
    'SAND': 'the-sandbox',
    'OUSG': 'ousg',
    'PYTH': 'pyth-network',
    'M': 'memecore',
    'TBTC': 'tbtc',
    'ETHX': 'stader-ethx',
    'USDX': 'usdx-money-usdx',
    'BTT': 'bittorrent',
    'USDY': 'ondo-us-dollar-yield',
    'RLUSD': 'ripple-usd',
    'JTO': 'jito-governance-token',
    'VSN': 'vision-3',
    'CBETH': 'coinbase-wrapped-staked-eth',
    'MORPHO': 'morpho',
    'FLOW': 'flow',
    'AB': 'newton-project',
    'WAL': 'walrus-2',
    'ZEC': 'zcash',
    'SWETH': 'sweth',
    'USD0': 'usual-usd',
    'BTC.B': 'bitcoin-avalanche-bridged-btc-b',
    'KTA': 'keeta',
    'MANA': 'decentraland',
    'BSV': 'bitcoin-cash-sv',
    'RSR': 'reserve-rights-token',
    'BRETT': 'based-brett',
    'B': 'build-on',
    'TEL': 'telcoin',
    'BDX': 'beldex',
    'STRK': 'starknet',
    'FRXETH': 'frax-ether',
    'USDD': 'usdd',
    'DYDX': 'dydx-chain',
    'TUSD': 'true-usd',
    'CORE': 'coredaoorg',
    'APE': 'apecoin',
    'HNT': 'helium',
    'SYRUP': 'syrup',
    'AIOZ': 'aioz-network',
    'ETHFI': 'ether-fi',
    'RUNE': 'thorchain',
    'AR': 'arweave',
    'NFT': 'apenft',
    'SUN': 'sun-token',
    'TRIP': 'trip',
    'FLUID': 'instadapp',
    'MOG': 'mog-coin',
    'COMP': 'compound-governance-token',
    'ZK': 'zksync',
    'SUPER': 'superfarm',
    'NEO': 'neo',
    'XCN': 'chain-2',
    'REKT': 'rekt-4',
    'EIGEN': 'eigenlayer',
    'EUTBL': 'eutbl',
    'DSOL': 'drift-staked-sol',
    'USELESS': 'useless-3',
    'ZORA': 'zora',
    'BUSD': 'binance-peg-busd',
    'DOG': 'dog-go-to-the-moon-rune',
    'AMP': 'amp-token',
    'TURBO': 'turbo',
    'FRAX': 'frax',
    'TOSHI': 'toshi',
    'STEAKUSDC': 'steakhouse-usdc-morpho-vault',
    'DCR': 'decred',
    'USR': 'resolv-usr',
    'VELO': 'velo',
    'USDO': 'openeden-open-dollar',
    'POPCAT': 'popcat',
    'TRIBE': 'tribe-2',
    'CUSDO': 'compounding-open-dollar',
    'LPT': 'livepeer',
    'ABTC': 'abtc',
    'DASH': 'dash',
    'MEW': 'cat-in-a-dogs-world',
    'BERA': 'berachain-bera',
    'IOTX': 'iotex',
    'CWBTC': 'compound-wrapped-btc',
    'CHEEMS': 'cheems-token',
    'BTSE': 'btse-token',
    'SAFE': 'safe',
    'RLP': 'resolv-rlp',
    'MOCA': 'mocaverse',
    'BORG': 'swissborg',
    'OM': 'mantra-dao',
    'KAITO': 'kaito',
    'GLM': 'golem',
    'TFUEL': 'theta-fuel',
    'PROVE': 'succinct',
    'SUSDX': 'usdx-money-staked-usdx',
    'ARKM': 'arkham',
    'KSM': 'kusama',
    'PLUME': 'plume',
    'BCAP': 'blockchain-capital',
    'ASBNB': 'astherus-staked-bnb',
    'MYX': 'myx-finance',
    'BAT': 'basic-attention-token',
    'UNIBTC': 'universal-btc',
    'CKB': 'nervos-network',
    'OETH': 'origin-ether',
    'MX': 'mx-token',
    'SNX': 'havven',
    'SFP': 'safepal',
    'MINA': 'mina-protocol',
    'ZRO': 'layerzero',
    'GRASS': 'grass',
    'NXM': 'nxm',
    'EURC': 'euro-coin',
    'PNUT': 'peanut-the-squirrel',
    'CETH': 'compound-ether',
    'CONSCIOUS': 'conscious-token',
    'RSTETH': 'restaking-vault-eth',
    'QTUM': 'qtum',
    'TRAC': 'origintrail',
    'STHYPE': 'staked-hype',
    'ZIL': 'zilliqa',
    'GAS': 'gas',
    'BABYDOGE': 'baby-doge-coin',
    'NPC': 'non-playable-coin',
    'AUSD': 'agora-dollar',
    'RVN': 'ravencoin',
    'GOMINING': 'gmt-token',
    'USDA': 'usda-2',
    'ZRX': '0x',
    'METAL': 'metal-blockchain',
    'XNY': 'codatta',
    'ROSE': 'oasis-network',
    'SKL': 'skale',
    'WSTUSR': 'resolv-wstusr',
    'ASTR': 'astar',
    'EUL': 'euler',
    'BLUR': 'blur',
    'ZANO': 'zano',
    'MBG': 'mbg-by-multibank-group',
    'AGENTFUN': 'agentfun-ai',
    'EVA': 'evervalue-coin',
    'DLC': 'diamond-launch',
    'NOT': 'notcoin',
    'CELO': 'celo',
    'LGCT': 'legacy-token',
    'BIO': 'bio-protocol',
    'COW': 'cow-protocol',
    'PTGC': 'the-grays-currency',
    'ORDI': 'ordinals',
    'YFI': 'yearn-finance',
    'PC0000031': 'tradable-na-rent-financing-platform-sstn',
    'ZETA': 'zetachain',
    'SAHARA': 'sahara-ai',
    'WAETHWETH': 'wrapped-aave-ethereum-weth',
    'FBTC': 'ignition-fbtc',
    'TIBBIR': 'ribbita-by-virtuals',
    'MINIDOGE': 'minidoge-5',
    'OKT': 'oec-token',
    'IBERA': 'infrared-bera',
    'VTHO': 'vethor-token',
    'WILD': 'wilder-world',
    'SC': 'siacoin',
    'MAG7.SSI': 'mag7-ssi',
    'MGG': 'mimbogamegroup',
    'ETHW': 'ethereum-pow-iou',
    'DGB': 'digibyte',
    'ILV': 'illuvium',
    'VVS': 'vvs-finance',
    'NEIRO': 'neiro-3',
    'MOODENG': 'moo-deng',
    'ONE': 'harmony',
    'SUSHI': 'sushi',
    'ZIG': 'zignaly',
    'ANKR': 'ankr',
    'UXLINK': 'uxlink',
    'AIC': 'ai-companions',
    'OMNI': 'omni-network',
    'GMX': 'gmx',
    'KAU': 'kinesis-gold',
    'KMNO': 'kamino',
    'OSAK': 'osaka-protocol',
    'ULTIMA': 'ultima',
    'AURA': 'aura-on-sol',
    'RSWETH': 'restaked-swell-eth',
    'CPOOL': 'clearpool',
    'MELANIA': 'melania-meme',
    'MARSMI': 'marsmi',
    'XYO': 'xyo-network',
    'BABY': 'babylon',
    'WOO': 'woo-network',
    'EURS': 'stasis-eurs',
    'ERA': 'caldera',
    'KAG': 'kinesis-silver',
    'ORCA': 'orca',
    'CSPR': 'casper-network',
    'MPLX': 'metaplex',
    'ICX': 'icon',
    'ALT': 'altlayer',
    'REAL': 'reallink',
    'XCH': 'chia',
    'WMTX': 'world-mobile-token',
    'SOLO': 'solo-coin',
    'LIBERTY': 'torch-of-liberty',
    'ZEN': 'zencash',
    'DEUSD': 'elixir-deusd',
    'KET': 'ket',
    'CET': 'coinex-token',
    'GIGA': 'gigachad-2',
    'AI16Z': 'ai16z',
    'HSK': 'hashkey-ecopoints',
    'SRUSD': 'reservoir-srusd',
    'DEGEN': 'degen-base',
    'KUB': 'bitkub-coin',
    'PZETH': 'renzo-restaked-lst',
    'GMT': 'stepn',
    'MWETH': 'moonwell-flagship-eth-morpho-vault',
    'VANA': 'vana',
    'KDA': 'kadena',
    'CRVUSD': 'crvusd',
    'MASK': 'mask-network',
    'OSMO': 'osmosis',
    'XNO': 'nano',
    'USTBL': 'spiko-us-t-bills-money-market-fund',
    'TAG': 'tagger',
    'ENJ': 'enjincoin',
    'SPK': 'spark-2',
    'LAYER': 'solayer',
    'BOME': 'book-of-meme',
    'BLAST': 'blast',
    'LCX': 'lcx',
    'RLB': 'rollbit-coin',
    'REI': 'unit-00-rei',
    'ONT': 'ontology',
    'COTI': 'coti',
    'USDZ': 'anzen-usdz',
    'HOME': 'home',
    'VRA': 'verasity',
    'WAVES': 'waves',
    'STBTC': 'lorenzo-stbtc',
    'ALCH': 'alchemist-ai',
    'YU': 'yu',
    'ZENBTC': 'wrapped-zenbtc',
    'SBTC': 'sbtc-2',
    'SXP': 'swipe',
    'AMAPT': 'amnis-aptos',
    'OZO': 'ozone-chain',
    'ME': 'magic-eden',
    'SSOL': 'solayer-staked-sol',
    'DOLA': 'dola-usd',
    'IO': 'io',
    'ALEO': 'aleo',
    'UMA': 'uma',
    'REQ': 'request-network',
    'FXUSD': 'f-x-protocol-fxusd',
    'YUSD': 'yieldfi-ytoken',
    'CYBER': 'cyberconnect',
    'AIXBT': 'aixbt',
    'HBUSDT': 'hyperbeat-usdt',
    'COREUM': 'coreum',
    'GOHOME': 'gohome',
    'PYTHIA': 'pythia',
    'DAG': 'constellation-labs',
    'EDGE': 'definitive',
    'LUNA': 'terra-luna-2',
    'ACRED': 'apollo-diversified-credit-securitize-fund',
    'METIS': 'metis-token',
    'FAI': 'freysa-ai',
    'RUJI': 'rujira',
    'LRC': 'loopring',
    'PRIME': 'echelon-prime',
    'VCNT': 'vicicoin',
    'SIX': 'six',
    'ACH': 'alchemy-pay',
    'RED': 'redstone-oracles',
    'HIVE': 'hive',
    'MERL': 'merlin-chain',
    'NTGL': 'entangle',
    'BICO': 'biconomy',
    'WELL': 'moonwell-artemis',
    'XVS': 'venus',
    'WCFG': 'wrapped-centrifuge',
    'IKA': 'ika',
    'ONYC': 'onyc',
    'SQD': 'subsquid',
    'MEME': 'memecoin-2',
    'PC0000023': 'tradable-singapore-fintech-ssl-2',
    'FUN': 'funfair',
    'SN64': 'chutes',
    'PUMPBTC': 'pumpbtc',
    'AWE': 'stp-network',
    'SWOP': 'swop-2',
    'QUSDT': 'qusdt',
    'ANIME': 'anime',
    'TRB': 'tellor',
    'MANTA': 'manta-network',
    'IOST': 'iostoken',
    'CROSS': 'cross-2',
    'FIDA': 'bonfida',
    'PSOL': 'phantom-staked-sol',
    'WAETHUSDC': 'wrapped-aave-ethereum-usdc',
    'PEOPLE': 'constitutiondao',
    'BANANA': 'banana-gun',
    'GOAT': 'goatseus-maximus',
    'AGI': 'delysium',
    'SGB': 'songbird',
    'ARDR': 'ardor',
    'STRAX': 'stratis',
    'AVUSD': 'avant-usd',
    'SIGN': 'sign-global',
    'PAAL': 'paal-ai',
    'YGG': 'yield-guild-games',
    'BITCOIN': 'harrypotterobamasonic10in',
    'SVL': 'slash-vision-labs',
    'API3': 'api3',
    'TRWA': 'tharwa',
    'CARV': 'carv',
    'DIA': 'dia-data',
    'HONEY': 'hivemapper',
    'EWT': 'energy-web-token',
    'SAVUSD': 'avant-staked-usd',
    'AGIX': 'singularitynet',
    'POWR': 'power-ledger',
    'FXSAVE': 'fx-usd-saving',
    'REUSD': 'resupply-usd',
    'PCI': 'pay-coin',
    'LQTY': 'liquity',
    'AEVO': 'aevo-exchange',
    'BNT': 'bancor',
    'LON': 'tokenlon',
    'ORBS': 'orbs',
    'TEMPLE': 'temple',
    'BAL': 'balancer',
    'G': 'g-token',
    'CETUS': 'cetus-protocol',
    'AGETH': 'kelp-gain',
    'BC': 'bc-token',
    'GAL': 'project-galaxy',
    'MVL': 'mass-vehicle-ledger',
    'VEE': 'blockv',
    'AUDIO': 'audius',
    'SHFL': 'shuffle-2',
    'DYM': 'dymension',
    'PHA': 'pha',
    'STS': 'beets-staked-sonic',
    'APU': 'apu-s-club',
    'COOKIE': 'cookie',
    'ARK': 'ark',
    'DBR': 'debridge',
    'BIM': 'bim-2',
    'SATS': 'sats-ordinals',
    'OFT': 'onfa',
    'LSK': 'lisk',
    'SPELL': 'spell-token',
    'B3': 'b3',
    'IUSD': 'infinifi-usd',
    'ERG': 'ergo',
    'TDCCP': 'tdccp',
    'CGPT': 'chaingpt',
    'BLOCK': 'block-4',
    'SUSDA': 'susda',
    'FLUX': 'zelcash',
    'WAETHUSDT': 'wrapped-aave-ethereum-usdt',
    'POKT': 'pocket-network',
    'CHR': 'chromaway',
    'CSUSDL': 'coinshift-usdl-morpho-vault',
    'PUNDIX': 'pundi-x-2',
    'ABT': 'arcblock',
    'MAGIC': 'magic',
    'VBETH': 'vaultbridge-bridged-eth-katana',
    'USTC': 'terrausd',
    'REUSDC': 'relend-usdc',
    'DOLO': 'dolomite',
    'UFART': 'unit-fartcoin',
    'CTSI': 'cartesi',
    'VBUSDC': 'vaultbridge-bridged-usdc-katana',
    'PUFF': 'puff-the-dragon',
    'SONIC': 'sonic-svm',
    'USDL': 'lift-dollar',
    'SOPH': 'sophon',
    'LA': 'lagrange',
    'SAGA': 'saga-2',
    'XUSD': 'straitsx-xusd',
    'ONG': 'ong',
    'SCR': 'scroll',
    'SOON': 'soon-2',
    'STEEM': 'steem',
    'WHITE': 'whiteheart',
    'CULT': 'milady-cult-coin',
    'BNKR': 'bankercoin-2',
    'NEWT': 'newton-protocol',
    'LQ': 'liqwid-finance',
    'SFRAX': 'staked-frax',
    'PEAQ': 'peaq-2',
    'DOGS': 'dogs-2',
    'ID': 'space-id',
    'RLC': 'iexec-rlc',
    'INC': 'incrypt',
    'BDCA': 'bitdca',
    'KNC': 'kyber-network-crystal',
    'GAME': 'gamebuild',
    'XRD': 'radix',
    'BANANAS31': 'banana-for-scale-2',
    'NKYC': 'nkyc-token',
    'PIN': 'pinlink',
    'NMR': 'numeraire',
    'ZKJ': 'polyhedra-network',
    'USDN': 'noble-dollar-usdn',
    'SLP': 'smooth-love-potion',
    'EKUBO': 'ekubo-protocol',
    'JSK': 'joystick-labs',
    'AUCTION': 'auction',
    'OG': 'og-fan-token',
    'ZRC': 'zircuit',
    'POND': 'marlin',
    'INIT': 'initia',
    'TOKABU': 'the-spirit-of-gambling',
    'MEDXT': 'medxt',
    'RSC': 'researchcoin',
    'BUCK': 'bucket-protocol-buck-stablecoin',
    'SOLV': 'solv-protocol',
    'SSV': 'ssv-network',
    'AITECH': 'solidus-aitech',
    'XAI': 'xai-blockchain',
    'SOSO': 'sosovalue',
    'BAN': 'comedian',
    'SIREN': 'siren-2',
    'TOWNS': 'towns',
    'MTL': 'metal',
    'MOVR': 'moonriver',
    'ZEDXION': 'zedxion',
    'BTU': 'btu-protocol',
    'SKI': 'ski-mask-dog',
    'HUMA': 'huma-finance',
    'WNXM': 'wrapped-nxm',
    'LISTA': 'lista',
    'BGSC': 'bugscoin',
    'RUSD': 'reservoir-rusd',
    'WIN': 'wink',
    'DESO': 'deso',
    'VANRY': 'vanar-chain',
    'H': 'humanity',
    'OCEAN': 'ocean-protocol',
    'ORAI': 'oraichain-token',
    'CCD': 'concordium',
    'WCT': 'connect-token-wct',
    'NILA': 'mindwavedao',
    'AO': 'ao-computer',
    'GNS': 'gains-network',
    'QANX': 'qanplatform',
    'ANYONE': 'airtor-protocol',
    'UNIETH': 'universal-eth',
    'PEPEONTRON': 'pepeontron',
    'GFI': 'goldfinch',
    'NIL': 'nillion',
    'TPT': 'token-pocket',
    'MED': 'medibloc',
    'CBK': 'cobak-token',
    'ICNT': 'impossible-cloud-network-token',
    'HEGIC': 'hegic',
    'SCRT': 'secret',
    'WXRP': 'wrapped-xrp',
    'BYUSD': 'byusd',
    'LVLUSD': 'level-usd',
    'TREE': 'treehouse',
    'PEP': 'pepecoin-network',
    'ZND': 'znd-token',
    'STRIKE': 'strike',
    'GCB': 'global-commercial-business',
    'OAS': 'oasys',
    'NTRN': 'neutron-3',
    'SATUSD': 'satoshi-stablecoin',
    'SN': 'spacen',
    'CAT': 'simon-s-cat',
    'RIF': 'rif-token',
    'SCRVUSD': 'savings-crvusd',
    'INF': 'socean-staked-sol',
    'MIM': 'magic-internet-money-runes',
    'MAMO': 'mamo',
    'IAG': 'iagon',
    'BLACK': 'blackhole',
    'HP': 'hippo-protocol',
    'NMD': 'nexusmind',
    'ASONUSDC': 'aave-usdc-sonic',
    'ZENT': 'zentry',
    'AERGO': 'aergo',
    'LAUNCHCOIN': 'ben-pasternak',
    'SOLVBTC.JUP': 'solv-protocol-solvbtc-jupiter',
    'ELG': 'escoin-token',
    'THE': 'thena',
    'HUNT': 'hunt-token',
    'WPOL': 'wmatic',
    'EPIC': 'epic-chain',
    'C98': 'coin98',
    'HEART': 'humans-ai',
    'QKC': 'quark-chain',
    'REX': 'revox',
    'NUB': 'sillynubcat',
    'MNDE': 'marinade',
    'TMG': 't-mac-dao',
    'VBILL': 'vaneck-treasury-fund',
    'TAOBOT': 'tao-bot',
    'GUSD': 'gemini-dollar',
    'HDX': 'hydradx',
    'CKBTC': 'chain-key-bitcoin',
    'WKC': 'wiki-cat',
    'HFT': 'hashflow',
    'QI': 'benqi',
    'SERV': 'openserv',
    'DRV': 'derive',
    'GEOD': 'geodnet',
    'CTK': 'certik',
    'TUT': 'tutorial',
    'LHYPE': 'looped-hype',
    'CLANKER': 'tokenbot-2',
    'BERT': 'bertram-the-pomeranian',
    'OMI': 'ecomi',
    'WBTC.E': 'avalanche-old-bridged-wbtc-avalanche',
    'WOLF': 'landwolf-0x67',
    'BOBA': 'boba-network',
    'USUALX': 'usualx',
    'HT': 'huobi-token',
    'PEAS': 'peapods-finance',
    'EURCV': 'societe-generale-forge-eurcv',
    'HASHAI': 'hashai',
    'GODS': 'gods-unchained',
    'KEYCAT': 'keyboard-cat',
    'QRL': 'quantum-resistant-ledger',
    'FIUSD': 'sygnum-fiusd-liquidity-fund',
    'M87': 'messier',
    'AURORA': 'aurora-near',
    'USDM': 'mountain-protocol-usdm',
    'USDAI': 'usdai',
    'USD+': 'usd',
    'ETN': 'electroneum',
    'CHILLGUY': 'chill-guy',
    'SBUSDT': 'sui-bridged-usdt-sui',
    'ACS': 'access-protocol',
    '0X0': '0x0-ai-ai-smart-contract',
    'BB': 'bouncebit',
    'FWOG': 'fwog',
    'QKA': 'qkacoin',
    'COCA': 'coca',
    'CORN': 'corn-3',
    'HMSTR': 'hamster-kombat',
    'SD': 'stader',
    'RESOLV': 'resolv',
    'DAKU': 'daku-v2',
    'PRO': 'propy',
    'TRUAPT': 'trufin-staked-apt',
    'SX': 'sx-network-2',
    'KERNEL': 'kernel-2',
    'UNP': 'unipoly',
    'MNEE': 'mnee-usd-stablecoin',
    'YALA': 'yala',
    'UQC': 'uquid-coin',
    'GP': 'graphite-protocol',
    'MIN': 'minswap',
    'ZEUS': 'zeus-network',
    'SUNDOG': 'sundog',
    'ARRR': 'pirate-chain',
    'RARE': 'superrare',
    'LUCKYMOON': 'lucky-moon',
    'CELR': 'celer-network',
    'IGT': 'infinitar-governance-token',
    'GEN': 'general',
    'UPP': 'uppserc',
    'SANTOS': 'santos-fc-fan-token',
    'A2Z': 'arena-z',
  };
  
  // Fetch stock price with caching
  Future<double?> fetchStockPrice(String symbol) async {
    final cacheKey = 'stock_$symbol';
    
    // Check cache first
    if (_priceCache.containsKey(cacheKey)) {
      final cached = _priceCache[cacheKey]!;
      if (!cached.isExpired(_cacheDuration)) {
        return cached.data;
      }
    }
    
    // Fetch from API
    try {
      final url = Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$symbol?range=1d&interval=1m');
      final response = await http.get(url, headers: {'User-Agent': 'Mozilla/5.0'});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['chart']['result'];
        if (result != null && result.isNotEmpty) {
          final price = result[0]['meta']['regularMarketPrice']?.toDouble();
          if (price != null) {
            _priceCache[cacheKey] = CacheEntry(price);
            return price;
          }
        }
      } else {
        debugPrint('Yahoo chart API failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching Yahoo price for $symbol: $e');
    }
    
    return null;
  }
  
  // Fetch crypto price with multiple API fallbacks and caching
  Future<double?> fetchCryptoPrice(String symbol) async {
    final cacheKey = 'crypto_$symbol';
    
    // Check cache first
    if (_priceCache.containsKey(cacheKey)) {
      final cached = _priceCache[cacheKey]!;
      if (!cached.isExpired(_cacheDuration)) {
        return cached.data;
      }
    }
    
    // Try CoinGecko first
    String coinId = _cryptoSymbolToIdMap[symbol.toUpperCase()] ?? symbol.toLowerCase();
    
    // Special handling for BONK to ensure correct ID
    if (symbol.toUpperCase() == 'BONK') {
      coinId = 'bonk';
    }
    
    double? price = await _fetchFromCoinGecko(coinId);
    
    // If CoinGecko fails, try CoinCap
    price ??= await _fetchFromCoinCap(symbol);
    
    // If both fail, try CryptoCompare
    price ??= await _fetchFromCryptoCompare(symbol);
    
    // Cache the result if successful
    if (price != null) {
      _priceCache[cacheKey] = CacheEntry(price);
    }
    
    return price;
  }
  
  // CoinGecko API
  Future<double?> _fetchFromCoinGecko(String coinId) async {
    try {
      final url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=$coinId&vs_currencies=usd');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data.isNotEmpty && data[coinId] != null) {
          return data[coinId]['usd']?.toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error fetching CoinGecko price for $coinId: $e');
    }
    return null;
  }
  
  // CoinCap API (free, no signup required)
  Future<double?> _fetchFromCoinCap(String symbol) async {
    try {
      final url = Uri.parse('https://api.coincap.io/v2/assets?search=$symbol');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          // Find exact match or first result
          var asset = data['data'].firstWhere(
            (asset) => asset['symbol'] == symbol.toUpperCase(),
            orElse: () => data['data'][0],
          );
          return double.tryParse(asset['priceUsd']?.toString() ?? '');
        }
      }
    } catch (e) {
      debugPrint('Error fetching CoinCap price for $symbol: $e');
    }
    return null;
  }
  
  // CryptoCompare API (free, no signup required)
  Future<double?> _fetchFromCryptoCompare(String symbol) async {
    try {
      final url = Uri.parse('https://min-api.cryptocompare.com/data/price?fsym=$symbol&tsyms=USD');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['USD'] != null) {
          return data['USD']?.toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error fetching CryptoCompare price for $symbol: $e');
    }
    return null;
  }
  
  // Fetch exchange rates with caching
  Future<Map<String, double>> fetchExchangeRates(String baseCurrency) async {
    final cacheKey = 'rates_$baseCurrency';
    
    // Check cache first
    if (_exchangeRateCache.containsKey(cacheKey)) {
      final cached = _exchangeRateCache[cacheKey]!;
      if (!cached.isExpired(_cacheDuration)) {
        return cached.data;
      }
    }
    
    try {
      final response = await http.get(Uri.parse('https://api.frankfurter.app/latest?from=$baseCurrency'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = Map<String, double>.from(data['rates'])
          ..[data['base']] = 1.0;
        
        // Cache the result
        _exchangeRateCache[cacheKey] = CacheEntry(rates);
        return rates;
      } else {
        debugPrint('Exchange rate API failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
    }
    
    // Return default rates if API fails
    return {baseCurrency: 1.0};
  }
  
  // Clear cache (useful for testing or force refresh)
  void clearCache() {
    _priceCache.clear();
    _exchangeRateCache.clear();
  }
}