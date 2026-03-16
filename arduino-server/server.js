import { SerialPort } from '@serialport/serialport';
import { ReadlineParser } from '@serialport/parser-readline';

const portName = 'COM8'; // your Arduino COM port
const baudRate = 9600;

const port = new SerialPort({ path: portName, baudRate });
const parser = port.pipe(new ReadlineParser({ delimiter: '\n' }));

parser.on('data', (line) => {
  try {
    const reading = JSON.parse(line);
    console.log('Arduino reading:', reading);
  } catch {
    console.error('Invalid JSON:', line);
  }
});

port.on('open', () => console.log(`Serial port ${portName} opened at ${baudRate} baud`));
port.on('error', (err) => console.error('Serial port error:', err));
