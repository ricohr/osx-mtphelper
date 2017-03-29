"use strict";
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

const Chai = require('chai');
Chai.use(require('chai-as-promised'));
const expect = Chai.expect;
const FS = require('fs');
const Temp = require('temp');
const Mktmpdir = require('mktmpdir')
const IsDarwin = (require('os').platform() === 'darwin');

const MTP = require(__dirname + "/../electron-sample/mtphelper.js");
MTP.executable = __dirname + ((process.platform=="win32")? "/../MtpHelper/bin/Debug/mtphelper.exe": "/../MtpHelper/Debug/MtpHelper");
MTP.stdout_proc = ()=>{}
const MtpPromise = MTP.start(require("queue"));


let TargetDeviceId;

describe('MtpHelper', ()=>{
  it('debug/MtpHelper.json is equal to release/MtpHelper.json', ()=>{
    const base = __dirname + (IsDarwin ? "/../MtpHelper/" : "/../MtpHelper/bin/")
    const d = JSON.parse(FS.readFileSync(base + "Debug/MtpHelper.json"));
    const r = JSON.parse(FS.readFileSync(base + "Release/MtpHelper.json"));
    expect(d).to.deep.equal(r);
  });

  it('helper_version return version', ()=>{
    let pattern;
    if (IsDarwin) {
      pattern = /^MtpHelper version /
    } else {
      pattern = /^MtpHelper\.exe version /
    }
    return expect(new Promise((resolve, reject)=>{
      MtpPromise.then(()=>{
        resolve(MTP.helper_version);
      });
    })).eventually.to.match(pattern);
  });

  it('deviceList return deviceId', ()=>{
    return expect(new Promise((resolve, reject)=>{
      setTimeout(()=>{
        MTP.deviceList().then((list)=>{
          TargetDeviceId = Object.keys(list)[0];
          resolve(Object.keys(list));
        });
      }, 200);
    })).eventually.to.have.length.of.at.least(1);
  });


  describe('for devices', ()=>{
    describe('deviceInfo command', ()=>{
      let Result;
      before((done)=>{
        const device = new MTP.Device(TargetDeviceId);
        device.deviceInfo().then((result)=>{
          Result = result;
          done();
        });
      });

      it('return with a status=OK', ()=>{
        expect(Result).to.have.property('status', 'OK');
      });
      it('return with a VenderExtensionId as number', ()=>{
        expect(Result.VenderExtensionId).to.be.a('number');
      });
      it('return with a VenderExtensionVersion as number', ()=>{
        expect(Result.VenderExtensionVersion).to.be.a('number');
      });
      it('return with a DeviceVersion as string', ()=>{
        expect(Result.DeviceVersion).to.be.a('string');
      });
      it('return with a SerialNumber as string', ()=>{
        expect(Result.SerialNumber).to.be.a('string');
      });
      it('return with a FunctionalMode as number', ()=>{
        expect(Result.FunctionalMode).to.be.a('number');
      });
      it('return with a Manufacturer as string', ()=>{
        expect(Result.Manufacturer).to.be.a('string');
      });
      it('return with a Model as string', ()=>{
        expect(Result.Model).to.be.a('string');
      });
      it('return with a StandardVersion as number', ()=>{
        expect(Result.StandardVersion).to.be.a('number');
      });

      it('with invalid deviceId, return "Device not found"', ()=>{
        const Result = (new MTP.Device(TargetDeviceId + '-invalid')).deviceInfo();
        return expect(Result).eventually.to.have.property('status', 'Device not found');
      });

      it('without deviceId, return "Invalid parameter"', ()=>{
        const Result = MTP.request('deviceInfo');
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(0 for 1)');
      });

      it('with too many parameter, return "Invalid parameter"', ()=>{
        const Result = MTP.request('deviceInfo ' + TargetDeviceId + ' foobar');
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(2 for 1)');
      });
    });


    describe('getPropDesc command', ()=>{
      describe('RGBGain', ()=>{
        // min-max, string
        const Type = 'string';
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.getPropDesc('RGBGain').then((result)=>{
            Result = result;
            done();
          });
        });

        it('return with status=OK', ()=>{
          expect(Result).to.have.property('status', 'OK');
        });
        it('return with min', ()=>{
          expect(Result.min).to.be.a(Type);
        });
        it('return with max', ()=>{
          expect(Result.max).to.be.a(Type);
        });
        it('return with step', ()=>{
          expect(Result.max).to.be.a(Type);
        });
        it('return without values', ()=>{
          expect(Result).to.not.have.property('values');
        });
        it('return with factory_default_value', ()=>{
          expect(Result.factory_default_value).to.be.a(Type);
        });
        it('return with current', ()=>{
          expect(Result.current).to.be.a(Type);
        });
        it('return with get_set=1', ()=>{
          expect(Result.get_set).to.equal(1);
        });
      });


      describe('WhiteBalance', ()=>{
        // enum, number
        const Type = 'number';
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.getPropDesc('WhiteBalance').then((result)=>{
            Result = result;
            done();
          });
        });

        it('return with status=OK', ()=>{
          expect(Result).to.have.property('status', 'OK');
        });
        it('return without min', ()=>{
          expect(Result).to.not.have.property('min');
        });
        it('return without max', ()=>{
          expect(Result).to.not.have.property('max');
        });
        it('return without step', ()=>{
          expect(Result).to.not.have.property('step');
        });
        it('return without values', ()=>{
          expect(Result.values).to.be.an('array');
        });
        it('return with factory_default_value', ()=>{
          expect(Result.factory_default_value).to.be.a(Type);
        });
        it('return with current', ()=>{
          expect(Result.current).to.be.a(Type);
        });
        it('return with get_set=1', ()=>{
          expect(Result.get_set).to.equal(1);
        });
      });


      describe('PerceivedDeviceType', ()=>{
        // readonly, number
        const Type = 'number';
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.getPropDesc('PerceivedDeviceType').then((result)=>{
            Result = result;
            done();
          });

          it('return with status=OK', ()=>{
            expect(Result).to.have.property('status', 'OK');
          });
          it('return without min', ()=>{
            expect(Result).to.not.have.property('min');
          });
          it('return without max', ()=>{
            expect(Result).to.not.have.property('max');
          });
          it('return without step', ()=>{
            expect(Result).to.not.have.property('step');
          });
          it('return with values', ()=>{
            expect(Result).to.not.have.property('values');
          });
          it('return with factory_default_value', ()=>{
            expect(Result.factory_default_value).to.be.a(Type);
          });
          it('return with current', ()=>{
            expect(Result.current).to.be.a(Type);
          });
          it('return with get_set=0', ()=>{
            expect(Result.get_set).to.equal(0);
          });
        });
      });


      it('with invalid propName, return "Invalid property key"', ()=>{
        const r = (new MTP.Device(TargetDeviceId)).getPropDesc('foobar');
        return expect(r).eventually.to.have.property('status', 'Invalid property key(foobar)');
      });

      it('with invalid deviceId, return "Device not found"', ()=>{
        const r = (new MTP.Device(TargetDeviceId + '-invalid')).getPropDesc('RGBGain');
        return expect(r).eventually.to.have.property('status', 'Device not found');
      });

      it('without deviceId and propName, return "Invalid parameter"', ()=>{
        const r = MTP.request('desc');
        return expect(r).eventually.to.have.property('status', 'Invalid parameter count(0 for 2)');
      });

      it('without propName, return "Invalid parameter"', ()=>{
        const r = MTP.request('desc ' + TargetDeviceId);
        return expect(r).eventually.to.have.property('status', 'Invalid parameter count(1 for 2)');
      });

      it('with too many parameter, return "Invalid parameter"', ()=>{
        const r = MTP.request('desc ' + TargetDeviceId + ' RGBGain foobar');
        return expect(r).eventually.to.have.property('status', 'Invalid parameter count(3 for 2)');
      });
    });


    let RGBgainValue;
    let WhiteBalanceValue;
    let PerceivedDeviceTypeValue;

    describe('getPropValue', ()=>{
      describe('RGBGain', ()=>{
        // min-max, string
        const Type = 'string';
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.getPropValue('RGBGain').then((result)=>{
            Result = result;
            RGBgainValue = result;
            done();
          });
        });

        it('return with status=OK', ()=>{
          expect(Result).to.have.property('status', 'OK');
        });
        it('return with current', ()=>{
          expect(Result.current).to.be.a(Type);
        });
      });

      describe('WhiteBalance', ()=>{
        // enum, number
        const Type = 'number';
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.getPropValue('WhiteBalance').then((result)=>{
            Result = result;
            WhiteBalanceValue = result;
            done();
          });
        });

        it('return with status=OK', ()=>{
          expect(Result).to.have.property('status', 'OK');
        });
        it('return with current', ()=>{
          expect(Result.current).to.be.a(Type);
        });
      });


      describe('PerceivedDeviceType', ()=>{
        // readonly, number
        const Type = 'number';
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.getPropValue('PerceivedDeviceType').then((result)=>{
            Result = result;
            PerceivedDeviceTypeValue = result;
            done();
          });
        });

        it('return with status=OK', ()=>{
          expect(Result).to.have.property('status', 'OK');
        });
        it('return with current', ()=>{
          expect(Result.current).to.be.a(Type);
        });
      });


      it('with invalid propName, return "Invalid property key"', ()=>{
        const Result = (new MTP.Device(TargetDeviceId)).getPropValue('foobar');
        return expect(Result).eventually.to.have.property('status', 'Invalid property key(foobar)');
      });

      it('with invalid deviceId, return "Device not found"', ()=>{
        const Result = (new MTP.Device(TargetDeviceId + '-invalid')).getPropValue('RGBGain');
        return expect(Result).eventually.to.have.property('status', 'Device not found');
      });

      it('without deviceId and propName, return "Invalid parameter"', ()=>{
        const Result = MTP.request('get');
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(0 for 2)');
      });

      it('without propName, return "Invalid parameter"', ()=>{
        const Result = MTP.request('get ' + TargetDeviceId);
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(1 for 2)');
      });

      it('with too many parameter, return "Invalid parameter"', ()=>{
        const Result = MTP.request('get ' + TargetDeviceId + ' RGBGain foobar');
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(3 for 2)');
      });
    });


    describe('setPropValue', ()=>{
      describe('RGBGain', ()=>{
        // min-max, string
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.setPropValue('RGBGain', RGBgainValue.current).then((result)=>{
            Result = result;
            done();
          });
        });

        it('return with status=OK', ()=>{
          expect(Result).to.have.property('status', 'OK');
        });
      });


      describe('WhiteBalance', ()=>{
        // enum, number
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.setPropValue('WhiteBalance', WhiteBalanceValue.current).then((result)=>{
            Result = result;
            done();
          });
        });

        it('return with status=OK', ()=>{
          expect(Result).to.have.property('status', 'OK');
        });
      });


      describe.skip('PerceivedDeviceType', ()=>{
        // readonly, number
        let Result;
        before((done)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.setPropValue('PerceivedDeviceType', PerceivedDeviceTypeValue.current).then((result)=>{
            Result = result;
            done();
          });
        });

        it('return with status!=OK', ()=>{
          expect(Result.status).to.not.equal('OK');
        });
      });


      it('with invalid propName, return "Invalid property key"', ()=>{
        const Result = (new MTP.Device(TargetDeviceId)).setPropValue('foobar', 0);
        return expect(Result).eventually.to.have.property('status', 'Invalid property key(foobar)');
      });

      it('with invalid deviceId, return "Device not found"', ()=>{
        const Result = (new MTP.Device(TargetDeviceId + '-invalid')).setPropValue('RGBGain', 0);
        return expect(Result).eventually.to.have.property('status', 'Device not found');
      });

      it('without deviceId, propName and value, return "Invalid parameter"', ()=>{
        const Result = MTP.request('set');
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(0 for 3)');
      });

      it('without propName and value, return "Invalid parameter"', ()=>{
        const Result = MTP.request('set ' + TargetDeviceId);
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(1 for 3)');
      });

      it('without value, return "Invalid parameter"', ()=>{
        const Result = MTP.request('set ' + TargetDeviceId + ' RGBGain');
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(2 for 3)');
      });

      it('with too many parameter, return "Invalid parameter"', ()=>{
        const Result = MTP.request('set ' + TargetDeviceId + ' RGBGain 180:100:180 foobar');
        return expect(Result).eventually.to.have.property('status', 'Invalid parameter count(4 for 3)');
      });
    });


    describe('sendConfigObject', ()=>{
      it('return status=OK when succeeded', ()=>{
        return expect(new Promise((resolve, reject)=>{
          Temp.open('json', (err, info)=>{
            FS.write(info.fd, '{"foo":"bar"}');
            FS.close(info.fd, (err)=>{
              const device = new MTP.Device(TargetDeviceId);
              device.sendConfigObject(info.path).then((result)=>{
                resolve(result);
                Temp.cleanup();
              });
            });
          });
        })).eventually.to.have.property('status', 'OK');
      });

      it('return failed when file i/o failed', ()=>{
        return expect(new Promise((resolve, reject)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.sendConfigObject('/foo/bar').then((result)=>{
            resolve(result.status);
          });
        })).eventually.to.not.equal('OK');
      });

      it('return status!=OK when empty file', ()=>{
        return expect(new Promise((resolve, reject)=>{
          Temp.open('json', (err, info)=>{
            FS.close(info.fd, (err)=>{
              const device = new MTP.Device(TargetDeviceId);
              device.sendConfigObject(info.path).then((result)=>{
                resolve(result);
                Temp.cleanup();
              });
            });
          });
        })).eventually.to.have.property('status', 'Invalid file content');
      });
    });


    describe('getConfigObject', ()=>{
      let body;
      it('return status=OK when succeeded', ()=>{
        return expect(new Promise((resolve, reject)=>{
          Temp.open('json', (err, info)=>{
            FS.close(info.fd, (err)=>{
              const device = new MTP.Device(TargetDeviceId);
              device.getConfigObject(info.path).then((result)=>{
                resolve(result);
                body = FS.readFileSync(info.path, 'utf-8');
                Temp.cleanup();
              });
            });
          });
        })).eventually.to.have.property('status', 'OK');
      });

      it('return last body of sendConfigObject', ()=>{
        expect(body).is.equal('{"foo":"bar"}');
      });

      it('return failed when file i/o failed', ()=>{
        return expect(new Promise((resolve, reject)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.getConfigObject('/foo/bar').then((result)=>{
            resolve(result.status);
          });
        })).eventually.to.not.equal('OK');
      });
    });


    describe('firmwareUpdate', ()=>{
      function execUpdate(filename, body) {
        return new Promise((resolve, reject)=>{
          Mktmpdir((err, dir, done)=>{
            const path = dir + '/' + filename;
            FS.writeFileSync(path, body);
            const device = new MTP.Device(TargetDeviceId);
            device.firmwareUpdate(path).then((result)=>{
              done();
              resolve(result);
            });
          });
        });
      }

      it('return status=OK when succeeded', ()=>{
        return expect(execUpdate('dk1_v001.frm', ' ')).eventually.to.have.property('status', 'OK');
      });
      it('return status=OK when succeeded, upcase', ()=>{
        return expect(execUpdate('DK1_V001.FRM', ' ')).eventually.to.have.property('status', 'OK');
      });

      it('return failed when file i/o failed', ()=>{
        return expect(new Promise((resolve, reject)=>{
          const device = new MTP.Device(TargetDeviceId);
          device.firmwareUpdate('/foo/bar').then((result)=>{
            resolve(result.status);
          });
        })).eventually.to.not.equal('OK');
      });

      it('return status!=OK when empty file', ()=>{
        return expect(execUpdate('dk1_v001.frm', '')).eventually.to.have.property('status', 'Invalid file content');
      });

      it('return status!=OK when invalid file name, invalid extension', ()=>{
        return expect(execUpdate('dk1_v001.bin', ' ')).eventually.to.have.property('status', 'Invalid file name');
      });
      it('return status!=OK when invalid file name, no extension', ()=>{
        return expect(execUpdate('dk1_v001_frm', ' ')).eventually.to.have.property('status', 'Invalid file name');
      });
      it('return status!=OK when invalid file name, no "_"', ()=>{
        return expect(execUpdate('dk1-v001', ' ')).eventually.to.have.property('status', 'Invalid file name');
      });
      it('return status!=OK when invalid file name, no "v"', ()=>{
        return expect(execUpdate('dk1_x001', ' ')).eventually.to.have.property('status', 'Invalid file name');
      });
      it('return status!=OK when invalid file name, invalid model', ()=>{
        return expect(execUpdate('dkA_v001', ' ')).eventually.to.have.property('status', 'Invalid file name');
      });
      it('return status!=OK when invalid file name, invalid version', ()=>{
        return expect(execUpdate('dk1_vA00', ' ')).eventually.to.have.property('status', 'Invalid file name');
      });
    });
  });
});
