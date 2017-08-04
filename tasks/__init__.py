import os

from invoke import task, Collection

from . import test, dc, kube, geth, util, swarm


COLLECTIONS = [test, dc, kube, geth, util, swarm]

ns = Collection()
for c in COLLECTIONS:
    ns.add_collection(c)

ns.configure(dict(
    project='geth',
    repo='docker-geth',
    pwd=os.getcwd(),
    docker=dict(
        user=os.getenv('DOCKER_USER'),
        tag='%s/%s:latest' % (os.getenv('DOCKER_USER'), 'geth')
    ),
    kube=dict(
        environment='testing'
    )
))
