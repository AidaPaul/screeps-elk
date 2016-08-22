#!/usr/bin/env python

import json
import screepsapi
from settings import screeps_credentials
import time
import sys

class ScreepsMemoryStats():

    def __init__(self, user, password, ptr=False):
        self.user = user
        self.password = password
        self.ptr = ptr

    def getScreepsAPI(self):
        if not self.__api:
            self.__api = screepsapi.API(self.user, self.password, self.ptr)
        return self.__api
    __api = False

    def run_forever(self):
        while True:
            self.run()
            time.sleep(10)

    def run(self):
        screeps = self.getScreepsAPI()
        stats = screeps.memory(path='___screeps_stats')
        if 'data' not in stats:
            return False

        confirm_queue =[]
        for tick,tickstats in stats['data'].items():
            for group,groupstats in tickstats.items():

                if not isinstance(groupstats, dict):
                    continue

                if 'subgroups' in groupstats:
                    for subgroup, statdata in groupstats.items():
                        if subgroup == 'subgroups':
                            continue

                        statdata[group] = subgroup
                        statdata['tick'] = int(tick)
                        statdata['timestamp'] = tickstats['time']
                        print(json.dumps(statdata));
                else:
                    groupstats['tick'] = int(tick)
                    groupstats['timestamp'] = tickstats['time']
                    print(json.dumps(groupstats));
                    sys.stdout.flush()
            confirm_queue.append(tick)

        self.confirm(confirm_queue)

    def confirm(self, ticks):
        javascript_clear = 'Stats.removeTick(' + json.dumps(ticks, separators=(',',':')) + ');'
        sconn = self.getScreepsAPI()
        sconn.console(javascript_clear)


if __name__ == "__main__":
    screepsconsole = ScreepsMemoryStats(**screeps_credentials)
    screepsconsole.run_forever()
