import React from 'react';
import SingleBook from './SingleBook';

const BookCard = ({ books }) => {
  console.log(books);
  return (
    <div className='grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4'>
      {books.map((book,index) => (
        <SingleBook book={book} key={book._id}/>
      ))}
    </div>
  );
};

export default BookCard;
