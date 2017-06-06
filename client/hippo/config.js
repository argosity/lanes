import Config from './models/config';

const ConfigInstance = Config.create({
    storage: localStorage,
    jsonify: true,
});

export default ConfigInstance;
