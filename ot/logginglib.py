import logging

def configureLogger(loggerName):
    root = logging.getLogger()
    root.setLevel(logging.DEBUG)
    logging.basicConfig(filename='{0}.log'.format(loggerName), level=logging.DEBUG)
    
    logger = logging.getLogger('{0}'.format(loggerName))

    # Create console handler and set its format.
    c_handler = logging.StreamHandler()
    c_handler.setLevel(logging.INFO)
    c_format = logging.Formatter('%(name)s - %(levelname)s - %(message)s')
    f_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    c_handler.setFormatter(c_format)

    # Add handlers to the logger
    logger.addHandler(c_handler)
    
    return logger
