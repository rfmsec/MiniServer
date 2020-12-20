import flask
import datetime
import socket
app = flask.Flask(__name__)


@app.route('/')
def index():
    ip_address = flask.request.remote_addr
    hostname = socket.gethostname()
    local_ip = socket.gethostbyname(hostname)
    return '''
<html>
    <head>
        <title>Home Page - TEG server 1</title>
    </head>
    <body>
        Hello user, welcome to TEG server!<br><br>
        Your IP address is: ''' + ip_address + '''<br>
        The server IP address is: ''' + local_ip + '''<br>
        The current date is: ''' + datetime.datetime.now().strftime("%d/%m/%Y  %H:%M:%S") + '''<br>
    </body>
</html>'''

if __name__ == '__main__':
    app.run(host="0.0.0.0", port="8080")