import flask
app = flask.Flask(__name__)
api_key = ''

PREFIX = "/grunkor"

import json
import requests

def insidan(path):
    cookie = flask.request.cookies['_open_project_session']
    return requests.get('https://insidan.holgerspexet.se/api/v3' + path,
                        cookies={'_open_project_session' : cookie})

def insidan_adm(path):
    return requests.get('https://insidan.holgerspexet.se/api/v3' + path,
                        auth=('apikey', api_key))

@app.route(PREFIX + "/emails")
def emails():
    r = insidan('/users?&pageSize=1000')
    if not r.status_code == requests.codes.ok:
        1/0 # https://www.youtube.com/watch?v=dQw4w9WgXcQ

    res = [ x['login'] for x in
            r.json()['_embedded']['elements'] ]
    res = [ x for x in res if '@' in x ]
    res.sort()

    return flask.Response("\n".join(res), mimetype='text/plain')

if __name__ == '__main__':
      app.run(debug=True, host='0.0.0.0', port=8081)
