module.exports = {
  config: {
    updateChannel: 'stable',

    fontSize: 12,

    fontFamily:
      '"MesloLGS NF", Menlo, "DejaVu Sans Mono", Consolas, "Lucida Console", monospace',
    fontWeight: 'normal',

    fontWeightBold: 'bold',

    cursorColor: 'rgba(248,28,229,0.8)',

    cursorAccentColor: '#000',

    // `'BEAM'` for |, `'UNDERLINE'` for _, `'BLOCK'` for █
    cursorShape: 'BEAM',

    cursorBlink: false,

    // color of the text
    foregroundColor: '#fff',

    backgroundColor: '#000',

    selectionColor: 'rgba(248,28,229,0.3)',

    borderColor: '#333',

    css: '',

    termCSS: '',

    showHamburgerMenu: '',

    showWindowControls: '',

    padding: '12px 14px 18px 14px',

    colors: {
      black: '#000000',
      red: '#C51E14',
      green: '#1DC121',
      yellow: '#C7C329',
      blue: '#0A2FC4',
      magenta: '#C839C5',
      cyan: '#20C5C6',
      white: '#C7C7C7',
      lightBlack: '#686868',
      lightRed: '#FD6F6B',
      lightGreen: '#67F86F',
      lightYellow: '#FFFA72',
      lightBlue: '#6A76FB',
      lightMagenta: '#FD7CFC',
      lightCyan: '#68FDFE',
      lightWhite: '#FFFFFF',
    },

    shell: '',

    shellArgs: ['--login'],

    env: {},

    bell: `false`,

    copyOnSelect: false,

    defaultSSHApp: true,

    // Hyperline plugin settings
    hyperline: {
      plugins: ['hostname', 'ip', 'cpu', 'memory', 'network', 'spotify'],
    },

    // Hyper Pokemon
    pokemon: 'pikachu',

    // Hypest
    //hypest: {
    //  darkmode: true,
    //},
  },

  // a list of plugins to fetch and install from npm
  plugins: [
    'hyper-hide-scroll',
    //'hyper-material-theme',
    'hyper-opacity',
    'hyper-pane',
    'hyper-search',
    'hyper-simple-highlight-active-session',
    'hyper-tabs-enhanced',
    'hypercwd',
    'hyperline',
    'hyperterm-bold-tab',
    'hyper-pokemon',
    //'hyper-hypest',
    //'hyperocean'
  ],

  localPlugins: [],

  keymaps: {},
};
