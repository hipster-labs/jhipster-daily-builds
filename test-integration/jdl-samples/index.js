const ejs = require("ejs");
const fs = require("fs");
const path = require("path");
// const config = {
//   serviceDiscoveryType: ["eureka", "consul"],
//   authenticationType: ["jwt", "session", "oauth2"],
//   prodDatabaseType: ["mysql", "mariadb"],
//   cacheProvider: ["hazelcast", "ehcache", "infinispan", "memcached", "no"], //memcached

//   searchEngine: "elasticsearch", //optional, at the moment not covered
//   messageBroker: "useKakfa: = true" //optional, at the moment not covered
//   //Open API?
// };
const config = require("./config.json");

const filename = "templates/microservice-demo.jdl.ejs";
try {
  config.serviceDiscoveryType.forEach(sdType => {
    config.authenticationType.forEach(authType => {
      config.prodDatabaseType.forEach(proddbType => {
        config.cacheProvider.forEach(cacheType => {
          ejs.renderFile(
            filename,
            {
              sdType: sdType,
              authType: authType,
              proddbType: proddbType,
              cacheType: cacheType
            },
            function(err, str) {
              if (err) console.log(err);
              else {
                fs.mkdirSync(
                  path.join(
                    __dirname,
                    `/../jdl-samples/${sdType}-${authType}-${proddbType}-${cacheType}`
                  ),
                  { recursive: true },
                  err => {
                    if (err) throw err;
                  }
                );
                fs.writeFile(
                  path.join(
                    __dirname,
                    `/../jdl-samples/${sdType}-${authType}-${proddbType}-${cacheType}/microservice-demo.jdl`
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
  console.log(
    `Samples (${config.serviceDiscoveryType.length * config.authenticationType.length * config.prodDatabaseType.length * config.cacheProvider.length} files) generated succesfully.`
  );
  } catch (e) {
  console.error(e);
}
