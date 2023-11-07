import { readdir } from 'fs/promises';
import { parse } from 'yaml';
import cronParser from 'cron-parser';
import command from './command.mjs';
import { basename, join } from 'path';

export default async env => {
  const BaseApplicationGenerator = await env.requireGenerator('jhipster:base-application');
  return class extends BaseApplicationGenerator {
    context = {};

    get [BaseApplicationGenerator.INITIALIZING]() {
      return this.asInitializingTaskGroup({
        async initializingTemplateTask() {
          this.parseJHipsterArguments(command.arguments);
          this.parseJHipsterOptions(command.options);
        },
      });
    }

    get [BaseApplicationGenerator.PROMPTING]() {
      return this.asPromptingTaskGroup({
        async promptingTemplateTask() {},
      });
    }

    get [BaseApplicationGenerator.LOADING]() {
      return this.asLoadingTaskGroup({
        async loadingTemplateTask() {
          const workflowsPath = this.templatePath('../../../.github/workflows');
          const workflows = await readdir(workflowsPath);
          this.context.workflows = workflows
            .map(workflow => ({ workflow, content: parse(this.readDestination(join(workflowsPath, workflow))) }))
            .filter(workflow => workflow.content.jobs.applications && workflow.content.on.schedule?.[0]?.cron)
            .map(workflow => ({ ...workflow, workflowName: basename(workflow.workflow) }));

          for (const workflow of this.context.workflows) {
            const cron = cronParser.parseExpression(workflow.content.on.schedule[0].cron);
            workflow.cron = `${cron.fields.hour[0].toString().padStart(2, '0')}:${cron.fields.minute[0].toString().padStart(2, '0')}`;
          }
          this.context.workflows.sort((a, b) => a.cron.localeCompare(b.cron));
        },
      });
    }

    get [BaseApplicationGenerator.WRITING]() {
      return this.asWritingTaskGroup({
        async writingTemplateTask() {
          await this.writeFiles({
            sections: {
              files: [{ templates: ['README.md'] }],
            },
            context: this.context,
          });
        },
      });
    }
  };
};
