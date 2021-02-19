const ejs = require("ejs");
const fs = require("fs");
const path = require("path");
const config = require("./config.json");

const filename = "templates/microservice-demo.jdl.ejs";
try {
  config.serviceDiscoveryType.forEach(sdType => {
    config.buildTool.forEach(buildTool => {
      config.clientFramework.forEach(clientFramework => {
        config.authenticationType.forEach(authType => {
          config.cacheProvider.forEach(cacheType => {
            ejs.renderFile(
              filename,
              {
                sdType: sdType,
                buildTool: buildTool,
                clientFramework: clientFramework,
                authType: authType,
                cacheType: cacheType
              },
              function(err, str) {
                if (err) console.log(err);
                else {
                  fs.mkdirSync(
                    path.join(
                      __dirname,
                      `/../jdl-samples/${sdType}-${buildTool}-${authType}-${clientFramework}-${cacheType}`
                    ),
                    { recursive: true },
                    err => {
                      if (err) throw err;
                    }
                  );
                  fs.writeFile(
                    path.join(
                      __dirname,
                      `/../jdl-samples/${sdType}-${buildTool}-${authType}-${clientFramework}-${cacheType}/microservice-demo.jdl`
                    ),
                    str,
                    function(error, data) {
                      if (error) throw err;
                    }
                  );
                }
              }
            );
          });
        });
      });
    });
  });
  console.log(
    `Samples (${config.serviceDiscoveryType.length * config.buildTool.length * config.authenticationType.length * config.cacheProvider.length} files) generated successfully.`
  );
  } catch (e) {
  console.error(e);
}
