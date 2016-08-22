let logLevels = {
    0: {
        'name': 'Emergency',
    },
    1: {
        'name': 'Alert',
    },
    2: {
        'name': 'Critical',
    },
    3: {
        'name': 'Error',
    },
    4: {
        'name': 'Warning',
    },
    5: {
        'name': 'Notice',
    },
    6: {
        'name': 'Informational',
    },
    7: {
        'name': 'Debug',
    },
};

global.EMERG = 0;
global.ALERT = 1;
global.CRIT = 2;
global.ERR = 3;
global.WARNING = 4;
global.NOTICE = 5;
global.INFO = 6;
global.DEBUG = 7;

/**
 * Threshold from which we will always notify
 *
 * @type {number}
 */
const ALERT_THRESHOLD = 3;

/**
 * Formats and logs to console given message. If notify is set to true
 * then also sends out email notification.
 *
 * @param {string} message Message to be logged
 * @param {number|EMERG|ALERT|CRIT|ERR|WARNING|NOTICE|INFO|DEBUG} severity Severity level, must be a number corresponding to logLevel const
 * @param {boolean} notify Set to true if you want email notification to be sent
 * @returns {number|OK} OK or ERR_INVALID_ARGS if severity level doesn't exist
 */
RoomObject.prototype.log = function (message, severity = DEBUG, notify = false) {
    let severityObject = logLevels[severity];
    if (!severityObject) {
        this.log('Called log with invalid severity!', WARNING, true);
    }
    let tick = Game.time;
    let room;
    let id = this.id;
    if (!this.room) {
        // Most likely a room itself so we shall treat its name as room name
        room = this.name;
    } else {
        room = this.room.name;
    }
    let caller = this.toString().split(' ')[0];

    let logEntry = tick + ' (' + severityObject['name'] + ')[' + room + ']' + caller + '][' + id + ']: ' + message;
    console.log(logEntry);
    if (notify || severity <= ALERT_THRESHOLD) {
        Game.notify(logEntry);
    }
    return OK;
};

Room.prototype.log = RoomObject.prototype.log;
