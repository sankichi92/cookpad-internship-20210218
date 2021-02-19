import * as Index from '../ts/index';

describe("buf2str", () => {
  it('convert 0xff, 0xff', () => {
    const target = new Uint8Array([0xff, 0xff]);
    expect(Index.buf2str(target.buffer)).toEqual('ffff');
  });
  it('convert 0xff, 0xff', () => {
    const target = new Uint8Array([0x01, 0x02]);
    expect(Index.buf2str(target.buffer)).toEqual('0102');
  });
  it('convert empty', () => {
    const target = new Uint8Array([]);
    expect(Index.buf2str(target.buffer)).toEqual('');
  });
});

describe("str2buf", () => {
  it('convert ffff', () => {
    const target = new Uint8Array([0xff, 0xff]);
    const buf = Index.str2buf('ffff');
    expect(new Uint8Array(buf)).toEqual(target);
  });
  it('convert 0123', () => {
    const target = new Uint8Array([0x01, 0x23]);
    const buf = Index.str2buf('0123');
    expect(new Uint8Array(buf)).toEqual(target);
  });
  it('cannot convert ffff', () => {
    expect(() => Index.str2buf('fff')).toThrow(new Error('hash string has odd length'));
  });
});


describe("generate_salt_and_encrypted_pass", () => {
 it('generate pubkey', (done: DoneFn) => {
   Index.generate_salt_and_encrypted_pass("password").then(pair => {
     expect(pair.password.length).toEqual(64);
     expect(pair.pubkey.alg).toEqual('RSA-OAEP-256');
     done();
   });
 });
});

