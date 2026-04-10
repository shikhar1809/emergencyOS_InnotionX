const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const logger = require("firebase-functions/logger");

setGlobalOptions({ region: "asia-south1", maxInstances: 10 });

/**
 * Health check for monitoring / uptime.
 */
exports.health = onRequest({ cors: true }, (req, res) => {
  logger.info("health check");
  res.status(200).json({
    ok: true,
    service: "emergencyos-functions",
    region: "asia-south1",
  });
});
