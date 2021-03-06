export interface KeyPair {
  pass: string;
  salt: string;
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

export function generate_salt_and_encrypted_pass(
  password: string
): Promise<KeyPair> {
  const raw_pass = new TextEncoder().encode(password);
  return new Promise((resolve, reject) => {
    const buf = new Uint8Array(64);
    const salt = crypto.getRandomValues(buf);
    hmac(raw_pass, salt)
      .then((dig) => resolve({ pass: buf2str(dig), salt: buf2str(salt) }))
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
  key: string,
  token: string
): Promise<string> {
  return new Promise((resolve, reject) => {
    hmac(str2buf(pass), str2buf(key)).then((digested) => {
      const raw_token = str2buf(token);
      hmac(digested, raw_token)
        .then((tok) => {
          resolve(buf2str(tok));
        })
        .catch(reject);
    });
  });
}

let login_pass = '';
let login_username = '';

const login_btn = document.getElementById('login-confirm');
if (login_btn instanceof HTMLButtonElement) {
  login_btn.disabled = true;
}

function check_loginable() {
  return login_username.length > 0 && login_pass.length > 7;
}

document.getElementById('login-username')?.addEventListener('input', (e) => {
  const { target } = e;
  if (target instanceof HTMLInputElement) {
    login_username = target.value;
  }
  if (login_btn instanceof HTMLButtonElement) {
    login_btn.disabled = !check_loginable();
  }
});

document.getElementById('login-password')?.addEventListener('input', (e) => {
  const { target } = e;
  if (target instanceof HTMLInputElement) {
    login_pass = target.value;
  }
  if (login_btn instanceof HTMLButtonElement) {
    login_btn.disabled = !check_loginable();
  }
});

login_btn?.addEventListener('click', () => {
  const xhr = new XMLHttpRequest();
  xhr.open('POST', 'http://localhost:4567/challenge_token');
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.addEventListener('load', () => {
    const res = JSON.parse(xhr.response);
    const token: string = res.token;
    const salt: string = res.salt;
    const raw_pass = new TextEncoder().encode(login_pass);
    hmac_pass(buf2str(raw_pass), salt, token).then((res) => {
      const xhr2 = new XMLHttpRequest();
      xhr2.open('POST', 'http://localhost:4567/login');
      xhr2.setRequestHeader('Content-Type', 'application/json');
      xhr2.send(JSON.stringify({ token: res }));
      xhr2.addEventListener('load', () => {
        if (JSON.parse(xhr2.response).result) {
          window.location.href = '/';
        } else {
          window.alert('パスワードが違います');
        }
      });
    });
  });
  xhr.send(JSON.stringify({ user: login_username }));
});

let signup_pass = '';
let signup_username = '';

const signup_btn = document.getElementById('signup-confirm');
if (signup_btn instanceof HTMLButtonElement) {
  signup_btn.disabled = true;
}

function check_signupable() {
  return signup_username.length > 0 && signup_pass.length > 7;
}

document.getElementById('signup-username')?.addEventListener('input', (e) => {
  const { target } = e;
  if (target instanceof HTMLInputElement) {
    signup_username = target.value;
  }
  if (signup_btn instanceof HTMLButtonElement) {
    signup_btn.disabled = !check_signupable();
  }
});

document.getElementById('signup-password')?.addEventListener('input', (e) => {
  const { target } = e;
  if (target instanceof HTMLInputElement) {
    signup_pass = target.value;
  }
  if (signup_btn instanceof HTMLButtonElement) {
    signup_btn.disabled = !check_signupable();
  }
});

signup_btn?.addEventListener('click', () => {
  generate_salt_and_encrypted_pass(signup_pass).then((pair) => {
    const xhr = new XMLHttpRequest();
    xhr.open('POST', 'http://localhost:4567/signup');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.addEventListener('load', () => {
      if (JSON.parse(xhr.response).result) {
        window.location.href = '/';
      } else {
        window.alert('既に登録されています');
      }
    });
    xhr.send(
      JSON.stringify({
        user: signup_username,
        pass: pair.pass,
        salt: pair.salt,
      })
    );
  });
});

let count = 0;
const add_cand_btn = document.getElementById('add-cand');
add_cand_btn?.addEventListener('click', () => {
  const self_li = add_cand_btn.parentNode;
  const new_cand = document.createElement('li');
  const cand_name = document.createElement('input');
  cand_name.setAttribute('type', 'text');
  cand_name.setAttribute('name', 'cand' + (count++).toString());
  new_cand.appendChild(cand_name);
  self_li?.parentNode?.insertBefore(new_cand, self_li);
});
