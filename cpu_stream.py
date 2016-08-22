import screepsapi
from settings import screeps_credentials
import sys


class CpuStream(screepsapi.Socket):
    def set_subscriptions(self):
        self.subscribe_user('cpu')

    def process_cpu(self, ws, data):
        print(data)
        sys.stdout.flush()

if __name__ == "__main__":
    console = CpuStream(**screeps_credentials)
    console.start()
