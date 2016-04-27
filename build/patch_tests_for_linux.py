import os

debugFile = open('.build/debug.yaml', 'r+')
debugContent = debugFile.read()
newDebugContent = debugContent.replace(".xctest", "Test.xctest")
debugFile.seek(0)
debugFile.write(newDebugContent)
debugFile.truncate()
debugFile.close()