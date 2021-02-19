function generate_salt_and_encrypted_pass(password: string) {
  const encode = new TextEncoder();
  const raw_pass = encode.encode(password);
  new Promise((resolve, reject) => {
    const config = {
      name: "RSA-OAEP",
      modulusLength: 4096,
      publicExponent: new Uint8Array([1,0,1]),
      hash: "SHA-256",
    };
    crypto.subtle.generateKey(config, true, ["encrypt"]).then(key => {
      const config = {
        name: "RSA-OAEP",
      };
      const encrypted = crypto.subtle.encrypt(config, key.publicKey, raw_pass);
      const pubkey = crypto.subtle.exportKey("jwk", key.publicKey);
      resolve([encrypted, pubkey]);
    })
    .catch(e => reject(e))
  })
}
