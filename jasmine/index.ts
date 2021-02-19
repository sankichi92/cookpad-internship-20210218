import * as Index from '../ts/index';

describe('buf2str', () => {
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

describe('str2buf', () => {
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
    expect(() => Index.str2buf('fff')).toThrow(
      new Error('hash string has odd length')
    );
  });
});

describe('generate_salt_and_encrypted_pass', () => {
  it('generate pubkey', (done: DoneFn) => {
    Index.generate_salt_and_encrypted_pass('password').then((pair) => {
      expect(pair.password.length).toEqual(64);
      expect(pair.pubkey.alg).toEqual('RSA-OAEP-256');
      done();
    });
  });
});

describe('hmac', () => {
  it('hmac', (done: DoneFn) => {
    const pass = '7768617420646f2079612077616e7420666f72206e6f7468696e673f';
    const key = '4a656665';
    const result =
      '5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843';
    Index.hmac(Index.str2buf(pass), Index.str2buf(key)).then((dig) => {
      expect(Index.buf2str(dig)).toEqual(result);
    });
    done();
  });
});
