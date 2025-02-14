import React from 'react'

import { AiOutlineClose } from 'react-icons/ai'
import { PiBookOpenTextLight } from 'react-icons/pi';
import { BsInfoCircle } from 'react-icons/bs';

const BookModal = ({ book, onClose }) => {
  return (
    <div
      className='w-100 fixed bg-black bg-opacity-60 top-0 right-0 bottom-0 z-50 flex justify-center items-center'
      onClose={onClose}>

      <div
        onClick={(event) => event.stopPropagation()}
        className='w-[600px] max-w-full h-400 bg-white rounded-xl p-4 flex flex-col relative'>
        <AiOutlineClose
          className='absolute right-6 top-6 text-3xl text-red-600 cursor-pointer'
          onClick={onClose} />
        <h2 className='px-4 py-1 bg-red-300 rounded-lg'>
          {book.publishYear}
        </h2>
        <div className='flex justify-start items-center gap-x-2'>
          <PiBookOpenTextLight className='text-red-300 text-2xl' />
          <h2 className='my-1'>{book.title}</h2>
        </div>
        <div className='flex justify-start items-center gap-x-2'>
          <BsInfoCircle className='text-red-300' />
          <h2 className='my-1'>{book.author}</h2>
        </div>
        <p className='mt-2'>Anything you want to Show</p>
        <p className='my-2'>
          Amet sit pariatur occaecat labore velit nulla ad excepteur irure ullamco id incididunt irure adipisicing. Excepteur voluptate dolor aliquip labore laborum. Sit officia dolore excepteur eiusmod esse dolor minim. Minim nulla voluptate consequat dolor commodo anim nulla commodo. Exercitation in dolor id id reprehenderit. Laborum est dolor enim ipsum aliquip.
        </p>
      </div>
    </div>
  )
}

export default BookModal