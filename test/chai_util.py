import sys
import gzip
import pickle

def check_par(name, value, _type=int, _min=None, _max=None, _list=None):
    """Check parameters."""

    if _type !=None and type(value) != _type:
        raise Exception('Value of parameter "%s" is not a valid %s.'%(name, _type))

    if _list != None and value not in _list:
        raise Exception('Value of parameter "%s" is not in the valid list: %s.'%(name, _list))

    if _min != None and value < _min:
        raise Exception('Value of parameter "%s" is less than the min value: %s.'%(name, _min))

    if _max != None and value > _max:
        raise Exception('Value of parameter "%s" is more than the max value: %s.'%(name, _max))


def pkl_gz_load(filename):
    with gzip.open(filename,'rb') as f:
        return pickle.load(f)


def pkl_gz_dump(obj, filename):
    with gzip.open(filename,'wb') as f:
        pickle.dump(obj, f)


def tee(_string, fileobj=None):
    """Print both on stdout and in the file."""
    sys.stdout.write(_string)
    if fileobj:
        fileobj.write(_string)


def _format(_string, format_s='{}', style = None):
    """Add color formatting to string for printing in a terminal."""
    styles = {
            'green'   : '\033[37m\033[42m',
            'yellow'  : '\033[37m\033[43m',
            'red'     : '\033[37m\033[41m',
            None      : ''
            }

    if not style in styles.keys():
        raise Exception('Unknown style "%s"'%style)

    if style:
        return styles[style] + format_s.format(_string) + '\033[00m' 
    else:
        return format_s.format(_string)


from functools import wraps
import inspect

def initializer(init):
    """Automatic member initialization for class __init__."""
    names, varargs, keywords, defaults = inspect.getargspec(init)
    @wraps(init)
    def wrapper(self, *args, **kargs):
        for name, arg in zip(names[1:], args) + kargs.items():
            setattr(self, name, arg)
        for i in range(len(defaults)):
            index = -(i + 1)
            if not hasattr(self, names[index]):
                setattr(self, names[index], defaults[index])
        init(self, *args, **kargs)
    return wrapper

