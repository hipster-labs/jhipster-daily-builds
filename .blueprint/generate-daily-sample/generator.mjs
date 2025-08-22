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

    get [BaseApplicationGenerator.WRITING]() {
      return this.asAnyTaskGroup({
        async writingTemplateTask() {
          console.log(this.sampleName);
          const [sdType, buildTool, clientFramework, authType, cacheType] = this.sampleName.split('-');
          await this.writeFile('microservice-demo.jdl.ejs', path.join(this.destination ?? '', 'microservice-demo.jdl'), {
            sdType,
            buildTool,
            clientFramework,
            authType,
            cacheType,
          });
        },
      });
    }
  };
}
