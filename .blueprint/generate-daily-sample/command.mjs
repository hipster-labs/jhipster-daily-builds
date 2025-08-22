/**
 * @type {import('generator-jhipster').JHipsterCommandDefinition}
 */
const command = {
  configs: {
    sampleName: {
      argument: {
        description: 'Sample to generate',
        type: String,
        required: true,
      },
      scope: 'generator',
    },
    destination: {
      argument: {
        type: String,
      },
      scope: 'generator',
    },
  },
};

export default command;
