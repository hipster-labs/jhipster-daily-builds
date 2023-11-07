/**
 * @type {import('generator-jhipster').JHipsterCommandDefinition}
 */
const command = {
  options: {},
  configs: {
    main: {
      desc: 'Regenerate generator-jhispter references in README.md',
      cli: {
        type: Boolean,
      },
      scope: 'generator',
    },
  },
};

export default command;
