import path from 'path';

// eslint-disable-next-line import/prefer-default-export
export async function createGenerator(env) {
  /** @type {typeof import('generator-jhipster/generators/base-core').default} */
  let BaseApplicationGenerator;
  try {
    // Try to use locally installed generator-jhipster
    BaseApplicationGenerator = (await import('generator-jhipster/generators/base-core')).default;
  } catch {
    // Fallback to the currently running jhipster.
    const jhipsterGenerator = 'jhipster:base-core';
    BaseApplicationGenerator = await env.requireGenerator(jhipsterGenerator);
  }

  return class extends BaseApplicationGenerator {
    /** @type {string} */
    sampleName;
    /** @type {string} */
    destination;

    constructor(args, opts, features) {
      super(args, opts, {
        ...features,
      });
    }

    get [BaseApplicationGenerator.INITIALIZING]() {
      return this.asAnyTaskGroup({
        initializing() {
          this.destinationRoot(this.destination);
        },
      });
    }

    get [BaseApplicationGenerator.WRITING]() {
      return this.asAnyTaskGroup({
        async writingTemplateTask() {
          const [sdType, buildTool, authType, clientFramework, cacheType] = this.sampleName.split('-');
          await this.writeFiles({
            templates: ['microservice-demo.jdl'],
            context: {
              sdType,
              buildTool,
              clientFramework,
              authType,
              cacheType,
            },
          });

          this.log.info('Generated microservice-demo.jdl:');
          this.log(this.readDestination('microservice-demo.jdl'));
        },
      });
    }
  };
}
