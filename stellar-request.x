

%#include "xdr/Stellar-ledger-entries.h"

namespace stellar
{
enum PrivateKeyType
{
	PRIVATE_KEY_TYPE_ED25519 = KEY_TYPE_ED25519
};


union PrivateKey switch (PrivateKeyType type)
{
case PRIVATE_KEY_TYPE_ED25519:
	uint256 ed25519;
};
//to give a hint of what we want the receiver to do with this data, it is not required.
enum RequestOperationHint
{
	ADD_CONTACT = 1.	//request to save contained data
	REQUEST_TX = 2, //request a transaction. without defining the amount or anything.
	ADD_ACCOUNT = 3	 //request to save account (private key required)
};


typedef opaque utf8string<>; 
typedef string string256<256>;


enum AccountDataType
{
	NAME = 1,
	EMAIL = 2,
	PHONE = 3,
	ADDRESS = 4,
	SOCIAL_LINK = 5, //link to a social network account
	GROUP = 6 //group name associated to this account, it should be used as a tag.
};


union AccountData switch (AccountDataType)
{
	case NAME: 
	utf8string name;
	
	case EMAIL: 
	string256 email;
	
	case PHONE: 
	string32 phone;
	
	case ADDRESS: 
	utf8string address;
	
	case SOCIAL_LINK: 
	utf8string address;
	
	case GROUP: 
	string32 group;	

};

struct ReceiptRecord
{
	utf8string itemName;
	string256 itemID;
	int32 quantity;
	Price price;
	Asset asset;
}
struct Receipt
{
	uint64 date;	
	string256 receiptIdentifier;// id used to identify the receipt
	ReceiptRecord records<>;
}

enum RequestDataType
{
	RECEIPT = 1
};

union RequestData switch (RequestDataType)
{
	case RECEIPT:
	Receipt receipt;
};

enum RequestParameterType
{	
	ACCOUNT_PRIVATE = 1,	//account private key.
	STELLAR_ADDRESS = 2,	//federation address (if used, it has preference over ACCOUNT_ID and ACCOUNT_MEMO).
	ACCOUNT_ID = 3,			//public key address.
	ACCOUNT_MEMO = 4,		//memo may be needed to define destination account. 
	ACCOUNT_DATA =5,		//extra information of the contact requesting this operation. (we could move all account data and request data to this enum, removing that level)
	REQUEST_DATA =6,		//extra information about the operation contained in this request.
	REMOTE_DATA = 7,		//url that will return information for this request, reply must be base64 of a RequestEnvelope.
	REQUESTED_OPERATION_HINT =8,  //hint to decide what we want with these parameters.
	OPERATION = 9 //xdr operation, can be up to 100 in the same request.
};


//key-value pair
union RequestParameter switch (RequestParameterType)
{
	case ACCOUNT_PRIVATE: 
	PrivateKey privateKey;
	
	case STELLAR_ADDRESS: 
	string256 federationAddress; 
	
	case ACCOUNT_ID: 
	AccountID publicKey;
	
	case ACCOUNT_MEMO: 
	Memo memo;
	
	case ACCOUNT_DATA: 
	AccountDataType accountData;

	case REMOTE_DATA: 
	string256 url;	

	case REQUESTED_OPERATION_HINT: 
	RequestParameterType requestHint;

	case OPERATION: 
	Operation operation;
};

//struct containing a list of request parameters. 
//the serialization of this struct is intended to be shared in URI in base64 encoding without compression using protocol stellar://request?data=BASE64
//for QR codes, it should be compressed using zlib (deflate with zlib header), for a normal transaction it can reduce the size by a 50%. For multiple operation transaction, it can be even more reduction as same address may be repeated multiple times.
//this can mean a reduction as per my tests from QR version 10 to 6 or from a 20 to a 12
//first byte of zlib is indicating the compression type, 78 for deflate
struct RequestEnvelope
{
	RequestParameter parameter<>;
};

}


