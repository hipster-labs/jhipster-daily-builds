import { readdir } from 'fs/promises';
import { parse } from 'yaml';
import cronParser from 'cron-parser';
import { basename, join } from 'path';

export default async env => {
  const BaseApplicationGenerator = await env.requireGenerator('jhipster:base-core');
  return class extends BaseApplicationGenerator {
    main;
    context = {};

    async beforeQueue() {
      await this.composeWithJHipster('bootstrap');
    }

    get [BaseApplicationGenerator.LOADING]() {
      return this.asAnyTaskGroup({
        async loadingTemplateTask() {
          const workflowsPath = this.templatePath('../../../.github/workflows');
          const workflows = await readdir(workflowsPath);
          this.context.workflows = workflows
            .map(workflow => ({ workflow, content: parse(this.readDestination(join(workflowsPath, workflow))) }))
            .map(workflow => ({ ...workflow, workflowName: basename(workflow.workflow) }));

          if (this.main) {
            this.context.workflows = this.context.workflows.filter(
              ({ workflowName }) =>
                workflowName.startsWith('ng-') ||
                workflowName.startsWith('react-') ||
                workflowName.startsWith('vue-') ||
                workflowName.startsWith('elasticsearch') ||
                workflowName.startsWith('monolith-') ||
                workflowName.startsWith('no-') ||
                workflowName.startsWith('ms-') ||
                workflowName.startsWith('docker-') ||
                workflowName.startsWith('windows'),
            );
          } else {
            this.context.workflows = this.context.workflows.filter(workflow => workflow.content.on.schedule?.[0]?.cron);
          }
          for (const workflow of this.context.workflows) {
            const cron = cronParser.parseExpression(workflow.content.on.schedule[0].cron);
            workflow.cron = `${cron.fields.hour[0].toString().padStart(2, '0')}:${cron.fields.minute[0].toString().padStart(2, '0')}`;
          }
          this.context.workflows.sort((a, b) => a.cron.localeCompare(b.cron));
        },
      });
    }

    get [BaseApplicationGenerator.WRITING]() {
      return this.asAnyTaskGroup({
        async writingTemplateTask() {
          await this.writeFiles({
            sections: {
              files: [{ templates: [this.main ? 'README.main.md' : 'README.md'] }],
            },
            context: this.context,
          });
        },
      });
    }
  };
};
