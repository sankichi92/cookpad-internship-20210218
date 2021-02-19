export interface KeyPair {
  password: string;
  pubkey: JsonWebKey;
}

export function buf2str(buf: ArrayBuffer): string {
  const view = new Uint8Array(buf);
  return Array.prototype.map
    .call(view, (byte) => `00${byte.toString(16)}`.slice(-2))
    .join('');
}

export function str2buf(s: string): ArrayBuffer {
  if (s.length % 2 != 0) throw new Error('hash string has odd length');
  const buf = new Uint8Array(s.length / 2);
  for (let i = 0; i < s.length / 2; ++i) {
    buf[i] = parseInt(s.slice(i * 2, i * 2 + 2), 16);
  }
  return buf.buffer;
}

const keyConfig = {
  name: 'RSA-OAEP',
  modulusLength: 4096,
  publicExponent: new Uint8Array([1, 0, 1]),
  hash: 'SHA-256',
};
const encryptConfig = {
  name: 'RSA-OAEP',
};

export function digest_pass(
  pass: string,
  key: CryptoKey
): Promise<ArrayBuffer> {
  const raw_pass = new TextEncoder().encode(pass);
  return new Promise((resolve, reject) => {
    crypto.subtle
      .encrypt(encryptConfig, key, raw_pass)
      .then((encrypted) => {
        crypto.subtle
          .digest('SHA-256', encrypted)
          .then((password_digest) => {
            resolve(password_digest);
          })
          .catch(reject);
      })
      .catch(reject);
  });
}

export function generate_salt_and_encrypted_pass(
  password: string
): Promise<KeyPair> {
  return new Promise((resolve, reject) => {
    crypto.subtle
      .generateKey(keyConfig, true, ['encrypt', 'decrypt'])
      .then((key) => {
        crypto.subtle
          .exportKey('jwk', key.publicKey)
          .then((pubkey) => {
            digest_pass(password, key.publicKey).then((pass) =>
              resolve({
                password: buf2str(pass),
                pubkey,
              })
            );
          })
          .catch(reject);
      })
      .catch(reject);
  });
}

export function hmac(
  msg_buf: ArrayBuffer,
  key_buf: ArrayBuffer
): Promise<ArrayBuffer> {
  const msg = new Uint8Array(msg_buf);
  const key = new Uint8Array(key_buf);
  const ipad_k_m = new Uint8Array(64 + msg.byteLength);
  for (let i = 0; i < 64; ++i) {
    ipad_k_m[i] = 0x36;
  }
  for (let i = 0; i < key.byteLength; ++i) {
    ipad_k_m[i] ^= key[i];
  }
  for (let i = 0; i < msg.byteLength; ++i) {
    ipad_k_m[i + 64] = msg[i];
  }
  return new Promise((resolve, reject) => {
    crypto.subtle
      .digest('SHA-256', ipad_k_m)
      .then((i_dig_buf) => {
        const i_dig = new Uint8Array(i_dig_buf);
        const opad_k_m = new Uint8Array(64 + i_dig.byteLength);
        for (let i = 0; i < 64; ++i) {
          opad_k_m[i] = 0x5c;
        }
        for (let i = 0; i < key.byteLength; ++i) {
          opad_k_m[i] ^= key[i];
        }
        for (let i = 0; i < i_dig.byteLength; ++i) {
          opad_k_m[i + 64] = i_dig[i];
        }
        crypto.subtle.digest('SHA-256', opad_k_m).then(resolve).catch(reject);
      })
      .catch(reject);
  });
}

export function hmac_pass(
  pass: string,
  key: JsonWebKey,
  token: string
): Promise<string> {
  return new Promise((resolve, reject) => {
    crypto.subtle
      .importKey('jwk', key, 'RSA-OAEP', false, ['encrypt'])
      .then((cryptoKey) => {
        digest_pass(pass, cryptoKey).then((pass) => {
          const raw_token = str2buf(token);
          hmac(pass, raw_token)
            .then((dig) => {
              resolve(buf2str(dig));
            })
            .catch(reject);
        });
      })
      .catch(reject);
  });
}

let login_pass = "";
let login_username = "";

const login_btn = document.getElementById("login-confirm");
if (login_btn instanceof HTMLButtonElement) {
  login_btn.disabled = true;
}

function check_loginable() {
  return login_username.length > 0 && login_pass.length > 7;
}

document.getElementById("login-username")?.addEventListener("input", (e) => {
  const { target } = e;
  if (target instanceof HTMLInputElement) {
    login_username = target.value;
  }
  if (login_btn instanceof HTMLButtonElement) {
    login_btn.disabled = !check_loginable();
  }
});

document.getElementById("login-password")?.addEventListener("input", (e) => {
  const { target } = e;
  if (target instanceof HTMLInputElement) {
    login_pass = target.value;
  }
  if (login_btn instanceof HTMLButtonElement) {
    login_btn.disabled = !check_loginable();
  }
});

login_btn?.addEventListener("click", () => {
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "localhost:4567/api/challenge_token");
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.addEventListener("load", () => {
    if (xhr.responseType == "json") {
      const token : string = xhr.response.token;
      const key : JsonWebKey = xhr.response.key;
      hmac_pass(login_pass, key, token).then(res => {
        xhr.open("POST", "localhost:4567/api/login");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(JSON.stringify({user: login_username, token: res}));
        xhr.addEventListener("load", () => {
          window.location.href = "/";
        });
      });
    }
  });
  xhr.send(JSON.stringify({user: login_username}));
});
