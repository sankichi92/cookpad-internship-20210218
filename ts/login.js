let pass = '';
let user = '';

document.getElementById('password').addEventListener('input', (e) => {
  pass = e.target.value;
  submitButton.disabled = username_registered | (pass.length < 8);
});

document.getElementById('username').addEventListener('input', (e) => {
  is_exists(e.target.value);
  user = e.target.value;
});

const submitButton = document.getElementById('submit');
submitButton.addEventListener('click', () => {
  send_key(pass);
});

function send_key(pass) {
  const raw = new Uint16Array([].map.call(pass, (c) => c.charCodeAt(0))).buffer;
  const keyConfig = {
    name: 'RSA-OAEP',
    modulusLength: 4096,
    publicExponent: new Uint8Array([1, 0, 1]),
    hash: 'SHA-256',
  };
  crypto.subtle
    .generateKey(keyConfig, true, ['encrypt', 'decrypt'])
    .then((key) => {
      crypto.subtle.encrypt('RSA-OAEP', key.publicKey, raw).then((pass) => {
        crypto.subtle.exportKey('jwk', key.publicKey).then((key) => {
          const pass_str = btoa(String.fromCharCode(...new Uint8Array(pass)));
          const pass_pair = {
            user,
            pass: pass_str,
            key,
          };
          const xhr = new XMLHttpRequest();
          xhr.open('POST', 'http://localhost:4567/signup');
          xhr.setRequestHeader('Content-Type', 'application/json');
          console.log(JSON.stringify(pass_pair));
          xhr.send(JSON.stringify(pass_pair));
        });
      });
    });
}

username_registered = true;

function is_exists(user) {
  console.log('check ', user);
  const xhr = new XMLHttpRequest();
  xhr.addEventListener('load', () => {
    username_registered = JSON.parse(xhr.response).registered;
    submitButton.disabled = username_registered | (pass.length < 8);
  });
  xhr.open('POST', 'http://localhost:4567/api/user_check');
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send(JSON.stringify({ username: user }));
}
