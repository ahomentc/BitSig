const functions = require("firebase-functions");
const admin = require('firebase-admin'); // access to ifrebase realtime database
const firebase = admin.initializeApp();


exports.updateNumberAddressSignedWhenSign = functions.database.ref('/tokens/{token_id}/signer_addresses/{eth_address}').onCreate((snapshot, context) => {
	const token_id = context.params.token_id;
	const eth_address = context.params.eth_address;
	const promises = []
	return snapshot.ref.root.child('/numSignersForToken/' + token_id).transaction(counter_value => {
		return (counter_value || 0) + 1
	}).then(() => {
    	const promises = []
    	return snapshot.ref.root.child('/numSignersForToken/' + token_id).once('value', num_signers => {
    		var val = parseInt(num_signers.val())
			promises.push(snapshot.ref.root.child('/tokens/' + token_id + '/signer_addresses/' + eth_address).set(val));
			promises.push(snapshot.ref.root.child('/eth_addresses/' + eth_address + '/tokens_signed/' + token_id).set(val));
			return Promise.all(promises);
		}).catch(() => {return null});
	}).catch(() => {return null});
})











