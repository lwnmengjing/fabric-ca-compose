#!/bin/bash

#Pull Image
# docker pull hyperledger/fabric-ca:1.4.9 
# docker pull hyperledger/fabric-peer:2.3
# docker pull hyperledger/fabric-tools:2.3


#Setup TLS CA
docker-compose up -d ca-tls
sleep 2s

#Enroll TLS CA’s Admin
mkdir -p ${PWD}/tmp/hyperledger/tls-ca/crypto
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/tls-ca/admin
fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-adminpw@0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052

#Setup Orderer Org CA
docker-compose up -d rca-org0
sleep 2s

#Enroll Orderer Org’s CA Admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org0/ca/admin
fabric-ca-client enroll -d -u https://rca-org0-admin:rca-org0-adminpw@0.0.0.0:7053
fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererpw --id.type orderer -u https://0.0.0.0:7053
fabric-ca-client register -d --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://0.0.0.0:7053

#Setup Org1’s CA
docker-compose up -d rca-org1
sleep 2s

#Enroll Org1’s CA Admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org1/ca/admin
fabric-ca-client enroll -d -u https://rca-org1-admin:rca-org1-adminpw@0.0.0.0:7054
fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7054
fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7054
fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type user -u https://0.0.0.0:7054
fabric-ca-client register -d --id.name user-org1 --id.secret org1UserPW --id.type user -u https://0.0.0.0:7054

#Setup Org2’s CA
docker-compose up -d rca-org2
sleep 2s

#Enrolling Org2’s CA Admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org2/ca/admin
fabric-ca-client enroll -d -u https://rca-org2-admin:rca-org2-adminpw@0.0.0.0:7055
fabric-ca-client register -d --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7055
fabric-ca-client register -d --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7055
fabric-ca-client register -d --id.name admin-org2 --id.secret org2AdminPW --id.type user -u https://0.0.0.0:7055
fabric-ca-client register -d --id.name user-org2 --id.secret org2UserPW --id.type user -u https://0.0.0.0:7055

#Setup Peers
#Setup Org1’s Peers
#Enroll Peer1
mkdir -p ${PWD}/tmp/hyperledger/org1/peer1/assets/ca
cp ${PWD}/tmp/hyperledger/org1/ca/crypto/ca-cert.pem  ${PWD}/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7054

mkdir -p ${PWD}/tmp/hyperledger/org1/peer1/assets/tls-ca
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org1
mv ${PWD}/tmp/hyperledger/org1/peer1/tls-msp/keystore/$(ls ${PWD}/tmp/hyperledger/org1/peer1/tls-msp/keystore) ${PWD}/tmp/hyperledger/org1/peer1/tls-msp/keystore/key.pem

#Enroll Peer2
mkdir -p ${PWD}/tmp/hyperledger/org1/peer2/assets/ca
cp ${PWD}/tmp/hyperledger/org1/ca/crypto/ca-cert.pem  ${PWD}/tmp/hyperledger/org1/peer2/assets/ca/org1-ca-cert.pem

export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org1/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org1/peer2/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer2-org1:peer2PW@0.0.0.0:7054

mkdir -p ${PWD}/tmp/hyperledger/org1/peer2/assets/tls-ca
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/org1/peer2/assets/tls-ca/tls-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org1/peer2/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer2-org1:peer2PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org1

mv ${PWD}/tmp/hyperledger/org1/peer2/tls-msp/keystore/$(ls ${PWD}/tmp/hyperledger/org1/peer2/tls-msp/keystore)  ${PWD}/tmp/hyperledger/org1/peer2/tls-msp/keystore/key.pem

#Enroll Org1’s Admin
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org1/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-org1:org1AdminPW@0.0.0.0:7054

mkdir ${PWD}/tmp/hyperledger/org1/peer1/msp/admincerts
cp ${PWD}/tmp/hyperledger/org1/admin/msp/signcerts/cert.pem ${PWD}/tmp/hyperledger/org1/peer1/msp/admincerts/org1-admin-cert.pem

# mkdir ${PWD}/tmp/hyperledger/org1/peer2/msp/admincerts
# cp ${PWD}/tmp/hyperledger/org1/admin/msp/signcerts/cert.pem ${PWD}/tmp/hyperledger/org1/peer2/msp/admincerts/org1-admin-cert.pem

#Launch Org1’s Peers
docker-compose up -d peer1-org1

cat << EOF > ${PWD}/tmp/hyperledger/org1/peer2/msp/config.yaml
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: orderer
EOF

docker-compose up -d peer2-org1
sleep 4s

#Setup Org2’s Peers
#Enroll Peer1
mkdir -p ${PWD}/tmp/hyperledger/org2/peer1/assets/ca
cp ${PWD}/tmp/hyperledger/org2/ca/crypto/ca-cert.pem  ${PWD}/tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org2/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7055

mkdir -p ${PWD}/tmp/hyperledger/org2/peer1/assets/tls-ca
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org2

mv ${PWD}/tmp/hyperledger/org2/peer1/tls-msp/keystore/$(ls ${PWD}/tmp/hyperledger/org2/peer1/tls-msp/keystore)  ${PWD}/tmp/hyperledger/org2/peer1/tls-msp/keystore/key.pem

#Enroll Peer2
mkdir -p ${PWD}/tmp/hyperledger/org2/peer2/assets/ca
cp ${PWD}/tmp/hyperledger/org2/ca/crypto/ca-cert.pem  ${PWD}/tmp/hyperledger/org2/peer2/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org2/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org2/peer2/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer2-org2:peer2PW@0.0.0.0:7055

mkdir -p ${PWD}/tmp/hyperledger/org2/peer2/assets/tls-ca
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/org2/peer2/assets/tls-ca/tls-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org2/peer2/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer2-org2:peer2PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org2

mv ${PWD}/tmp/hyperledger/org2/peer2/tls-msp/keystore/$(ls ${PWD}/tmp/hyperledger/org2/peer2/tls-msp/keystore)  ${PWD}/tmp/hyperledger/org2/peer2/tls-msp/keystore/key.pem


#Enroll Org2’s Admin
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org2/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-org2:org2AdminPW@0.0.0.0:7055

mkdir ${PWD}/tmp/hyperledger/org2/peer1/msp/admincerts
cp ${PWD}/tmp/hyperledger/org2/admin/msp/signcerts/cert.pem ${PWD}/tmp/hyperledger/org2/peer1/msp/admincerts/org2-admin-cert.pem

# mkdir ${PWD}/tmp/hyperledger/org2/peer2/msp/admincerts
# cp ${PWD}/tmp/hyperledger/org2/admin/msp/signcerts/cert.pem ${PWD}/tmp/hyperledger/org2/peer2/msp/admincerts/org2-admin-cert.pem

#Launch Org2’s Peers
docker-compose up -d peer1-org2

cat << EOF > ${PWD}/tmp/hyperledger/org2/peer2/msp/config.yaml
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/0-0-0-0-7055.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7055.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7055.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7055.pem
    OrganizationalUnitIdentifier: orderer
EOF
docker-compose up -d peer2-org2
sleep 4s

#Setup Orderer
#Enroll Orderer
mkdir -p ${PWD}/tmp/hyperledger/org0/orderer/assets/ca
cp ${PWD}/tmp/hyperledger/org0/ca/crypto/ca-cert.pem ${PWD}/tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org0/orderer
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
fabric-ca-client enroll -d -u https://orderer1-org0:ordererpw@0.0.0.0:7053

mkdir -p ${PWD}/tmp/hyperledger/org0/orderer/assets/tls-ca
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/org0/orderer/assets/tls-ca/tls-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org0/orderer/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://orderer1-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org0


#Enroll Org0’s Admin
export FABRIC_CA_CLIENT_HOME=${PWD}/tmp/hyperledger/org0/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-org0:org0adminpw@0.0.0.0:7053

mkdir ${PWD}/tmp/hyperledger/org0/orderer/msp/admincerts
cp ${PWD}/tmp/hyperledger/org0/admin/msp/signcerts/cert.pem ${PWD}/tmp/hyperledger/org0/orderer/msp/admincerts/orderer-admin-cert.pem

mv ${PWD}/tmp/hyperledger/org0/orderer/tls-msp/keystore/$(ls ${PWD}/tmp/hyperledger/org0/orderer/tls-msp/keystore) ${PWD}/tmp/hyperledger/org0/orderer/tls-msp/keystore/key.pem

#Maks Org0 MSP
mkdir -p ${PWD}/tmp/hyperledger/org0/msp/admincerts
cp ${PWD}/tmp/hyperledger/org0/orderer/msp/admincerts/orderer-admin-cert.pem  ${PWD}/tmp/hyperledger/org0/msp/admincerts/admin-org0-cert.pem
mkdir ${PWD}/tmp/hyperledger/org0/msp/cacerts
cp ${PWD}/tmp/hyperledger/org0/ca/crypto/ca-cert.pem ${PWD}/tmp/hyperledger/org0/msp/cacerts/org0-ca-cert.pem
mkdir ${PWD}/tmp/hyperledger/org0/msp/tlscacerts
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/org0/msp/tlscacerts/tls-ca-cert.pem
mkdir ${PWD}/tmp/hyperledger/org0/msp/users

#Maks Org1 MSP
mkdir -p ${PWD}/tmp/hyperledger/org1/msp/admincerts
cp ${PWD}/tmp/hyperledger/org1/peer1/msp/admincerts/org1-admin-cert.pem  ${PWD}/tmp/hyperledger/org0/msp/admincerts/admin-org1-cert.pem
mkdir ${PWD}/tmp/hyperledger/org1/msp/cacerts
cp ${PWD}/tmp/hyperledger/org1/ca/crypto/ca-cert.pem ${PWD}/tmp/hyperledger/org1/msp/cacerts/org1-ca-cert.pem
mkdir ${PWD}/tmp/hyperledger/org1/msp/tlscacerts
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/org1/msp/tlscacerts/tls-ca-cert.pem
mkdir ${PWD}/tmp/hyperledger/org1/msp/users

#Maks Org2 MSP
mkdir -p ${PWD}/tmp/hyperledger/org2/msp/admincerts
cp  ${PWD}/tmp/hyperledger/org2/peer1/msp/admincerts/org2-admin-cert.pem ${PWD}/tmp/hyperledger/org2/msp/admincerts/admin-org2-cert.pem
mkdir ${PWD}/tmp/hyperledger/org2/msp/cacerts
cp ${PWD}/tmp/hyperledger/org2/ca/crypto/ca-cert.pem ${PWD}/tmp/hyperledger/org2/msp/cacerts/org2-ca-cert.pem
mkdir ${PWD}/tmp/hyperledger/org2/msp/tlscacerts
cp ${PWD}/tmp/hyperledger/tls/ca/crypto/tls-cert.pem ${PWD}/tmp/hyperledger/org2/msp/tlscacerts/tls-ca-cert.pem
mkdir ${PWD}/tmp/hyperledger/org2/msp/users

export FABRIC_CFG_PATH=${PWD}
configtxgen -profile OrgsOrdererGenesis -outputBlock ${PWD}/tmp/hyperledger/org0/orderer/genesis.block -channelID syschannel
configtxgen -profile OrgsChannel -outputCreateChannelTx ${PWD}/tmp/hyperledger/org0/orderer/channel.tx -channelID mychannel

#Launch Orderer
docker-compose up -d orderer1-org0

cp ${PWD}/tmp/hyperledger/org0/orderer/channel.tx ${PWD}/tmp/hyperledger/org1/peer1/assets/channel.tx
cp ${PWD}/tmp/hyperledger/org0/orderer/channel.tx ${PWD}/tmp/hyperledger/org1/peer2/assets/channel.tx

#Launch Cli
docker-compose up -d cli-org1
docker-compose up -d cli-org2

#docker exec -it cli-org1 sh
#export CORE_PEER_MSPCONFIGPATH=${PWD}/tmp/hyperledger/org1/peer1/msp
#peer channel create -c mychannel -f ${PWD}/tmp/hyperledger/org1/peer1/assets/channel.tx -o orderer1-org0:7050 --outputBlock ${PWD}/tmp/hyperledger/org1/peer1/assets/mychannel.block --tls --cafile ${PWD}/tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem