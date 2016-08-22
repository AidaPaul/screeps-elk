import screepsapi
from settings import screeps_credentials
import sys


class ConsoleStream(screepsapi.Socket):
    def set_subscriptions(self):
        self.subscribe_user('console')

    def process_log(self, ws, message):
        print(message)
        sys.stdout.flush()

if __name__ == "__main__":
    console = ConsoleStream(**screeps_credentials)
    console.start()
