import qi
import audio
import vision


class QiApplication:

    def __init__(self, ip="127.0.0.1", port=9559):
        connection_url = "tcp://" + ip + ":" + str(port)
        print("Connecting to nao-qi at {0} ...".format(connection_url))
        self.app = qi.Application(["--qi-url=" + connection_url])
        self.app.start()
        self.session = self.app.session

        self.audio = audio.Audio(self.session)
        self.vision = vision.Vision(self.session)

        self.audio.set_callback(self.send)
        self.vision.set_callback(self.send)

        # self.session.registerService(self.audio.module_name, self.audio)
        # self.session.registerService(self.vision.module_name, self.vision)

    def send(self, message):
        print("Sending event '{0}' as {1}".format(message['event'], message['dataType']))
        print("=" * 20)
        print(message['data'])
        print("=" * 20)
        # self.send_callback({ 'event': event, 'data':data, 'dataType': data_type})

    def run_forever(self):
        self.app.run()
