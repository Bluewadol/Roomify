const presets = require("railsui-tailwind-presets");
const execSync = require("child_process").execSync;
const outputRailsUI = execSync("bundle show railsui", { encoding: "utf-8" });
const rails_ui_path = outputRailsUI.trim() + "/**/*.rb";
const rails_ui_template_path = outputRailsUI.trim() + "/**/*.html.erb";

module.exports = {
  presets: [presets.hound],
  darkMode: false,
  content: [
    "./config/initializers/railsui_icon.rb",
    './app/assets/stylesheets/**/*.css',
    './app/components/**/*.html.erb',
    './app/components/**/*.rb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.html.erb',
    rails_ui_path,
    rails_ui_template_path
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#e6f0fa',
          100: '#cce1f5',
          200: '#99c3eb',
          300: '#66a5e0',
          400: '#3388d6',
          500: '#0056a9',
          600: '#004f98',
          700: '#004280',
          800: '#003a77',
          900: '#003066',
          950: '#00234d',
        },
        secondary: {
          50: '#fff3e0',
          100: '#ffe0b2',
          200: '#ffcc80',
          300: '#ffb74d',
          400: '#ffa726',
          500: '#ff8a00',
          600: '#f57c00',
          700: '#ef6c00',
          800: '#e65100',
          900: '#bf360c',
          950: '#8f2500',
        },
        gray: {
          50: '#f9fafb',
          100: '#f3f4f6',
          200: '#e5e7eb',
          300: '#d1d5db',
          400: '#9ca3af',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          800: '#1f2937',
          900: '#111827',
          950: '#030712',
        },
        success: {
          main: '#1e7e34',
        },
        danger: {
          main: '#be123c',
        },
        warning: {
          main: '#d39e00',
        },
        info: {
          main: '#117a8b',
        },
        light: {
          main: '#dae0e5',
        },
        dark: {
          main: '#23272b',
        },
      },
      keyframes: {
        'toast-from-right': {
          '0%': { transform: 'translateX(50%)', opacity: '0%' },
          '100%': { transform: 'translateX(0)', opacity: '100%' },
        },
        'toast-from-left': {
          '0%': { transform: 'translateX(-50%)', opacity: '0%' },
          '100%': { transform: 'translateX(0)', opacity: '100%' },
        },
      },
      animation: {
        'toast-from-right': 'toast-from-right 0.5s cubic-bezier(0.68, -0.55, 0.27, 1.55)',
        'toast-from-left': 'toast-from-left 0.5s cubic-bezier(0.68, -0.55, 0.27, 1.55)',
      },
    }
  },
  plugins: [
    function({ addComponents }) {
      addComponents({
        '.btn': {
          '@apply inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2': {},
        },
        '.btn-primary': {
          '@apply bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500': {},
        },
        '.btn-secondary': {
          '@apply bg-secondary-600 text-white hover:bg-secondary-700 focus:ring-secondary-500': {},
        },
        '.btn-light': {
          '@apply bg-gray-100 text-gray-700 hover:bg-gray-200 focus:ring-gray-500': {},
        },
        '.btn-dark': {
          '@apply bg-gray-800 text-white hover:bg-gray-900 focus:ring-gray-500': {},
        },
        '.btn-transparent': {
          '@apply bg-transparent text-gray-700 hover:bg-gray-100 focus:ring-gray-500': {},
        },
      })
    },
  ]
}
