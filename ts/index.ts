export interface KeyPair {
  password: string,
  pubkey: JsonWebKey
}

export function buf2str(buf: ArrayBuffer): string {
  const view = new Uint8Array(buf);
  return Array.prototype.map.call(view, byte => ("00" + byte.toString(16)).slice(-2)).join("")
}

export function generate_salt_and_encrypted_pass(password: string): Promise<KeyPair> {
  const encode = new TextEncoder();
  const raw_pass = encode.encode(password);
  return new Promise((resolve, reject) => {
    const config = {
      name: "RSA-OAEP",
      modulusLength: 4096,
      publicExponent: new Uint8Array([1,0,1]),
      hash: "SHA-256",
    };
    crypto.subtle.generateKey(config, true, ["encrypt", "decrypt"]).then(key => {
      const config = {
        name: "RSA-OAEP",
      };
      crypto.subtle.encrypt(config, key.publicKey, raw_pass).then(encrypted => {;
        crypto.subtle.exportKey("jwk", key.publicKey).then(pubkey => {
          resolve({password: buf2str(encrypted), pubkey});
        });
      });
    })
    .catch(e => reject(e))
  })
}
