from pybrain.structure import RecurrentNetwork, LinearLayer, SigmoidLayer, FullConnection, TanhLayer
from pybrain.datasets import SupervisedDataSet
from pybrain.supervised.trainers import BackpropTrainer
from pybrain.tools.shortcuts import buildNetwork

# n = RecurrentNetwork()
# n.addInputModule(LinearLayer(1, name='in'))
# n.addModule(SigmoidLayer(3, name='hidden'))
# n.addOutputModule(LinearLayer(1, name='out'))
# n.addConnection(FullConnection(n['in'], n['hidden'], name='c1'))
# n.addConnection(FullConnection(n['hidden'], n['out'], name='c2'))
# n.addRecurrentConnection(FullConnection(n['hidden'], n['hidden'], name='c3'))

n = buildNetwork(1, 1, 1, hiddenclass=SigmoidLayer)

ds = SupervisedDataSet(1, 1)
ds.addSample([1], [1])
ds.addSample([1], [1])
ds.addSample([1], [1])
# ds.addSample([2], [2])
# ds.addSample([2], [2])
# ds.addSample([3], [3])

trainer = BackpropTrainer(n, ds)
err = trainer.train()
# print(err)
n.reset()
print(n.activate([1]))
