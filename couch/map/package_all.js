
function(doc){
  if(doc.type === 'Package'){
    emit(doc._id, doc)
  }
}

