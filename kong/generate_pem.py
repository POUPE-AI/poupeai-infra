import sys
import base64
import requests
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPublicNumbers

def jwk_to_pem(jwk):
    """
    Converts a JWK dictionary to a PEM-formatted public key.
    """
    def base64url_decode(value):
        rem = len(value) % 4
        if rem > 0:
            value += '=' * (4 - rem)
        return base64.urlsafe_b64decode(value)

    n_bytes = base64url_decode(jwk['n'])
    e_bytes = base64url_decode(jwk['e'])
    
    n = int.from_bytes(n_bytes, 'big')
    e = int.from_bytes(e_bytes, 'big')

    public_numbers = RSAPublicNumbers(e, n)
    public_key = public_numbers.public_key()
    
    pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    return pem.decode('utf-8')

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python generate_pem.py <jwks_url>", file=sys.stderr)
        sys.exit(1)
        
    jwks_url = sys.argv[1]
    
    try:
        response = requests.get(jwks_url)
        response.raise_for_status()
        jwks = response.json()
        
        rsa_key = next((key for key in jwks['keys'] if key['kty'] == 'RSA' and key.get('use') == 'sig'), None)
        
        if rsa_key:
            pem_key = jwk_to_pem(rsa_key)
            print(pem_key)
        else:
            print("Nenhuma chave de assinatura RSA ('sig') encontrada no JWKS.", file=sys.stderr)
            sys.exit(1)
            
    except requests.exceptions.RequestException as e:
        print(f"Erro ao buscar JWKS: {e}", file=sys.stderr)
        sys.exit(1)
    except (KeyError, IndexError) as e:
        print(f"Formato JWKS inválido: {e}", file=sys.stderr)
        sys.exit(1)