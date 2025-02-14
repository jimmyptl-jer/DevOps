import mongoose from "mongoose"

const bookSchema = mongoose.Schema(
  {
    title:{
      type:String,
      required:[true,"Please add a name"]
    },
    author :{
      type: String ,  //string is the datatype of data that we are storing in our database
      required:[ true ,"please enter an company name"],
    },
    publishYear:{
      type:Number,//number is the datatype of data that we are storing in our database,
      required:true
    },
  },{
    timeStamp: true
  }
)

export const Book =  mongoose.model('Book',bookSchema)