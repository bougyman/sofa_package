
function(doc){
  if(doc.type === 'SofaPackage::Package'){
    emit(doc._id + ': ' + doc.pkgdesc, null)
  }
}

