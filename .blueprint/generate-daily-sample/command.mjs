import { asCommand } from 'generator-jhipster';

export default asCommand({
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
});
