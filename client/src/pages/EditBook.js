import React, { useEffect, useState } from 'react'
import BackButton from '../components/BackButton'
import Snipper from '../components/Spinner'

import axios from 'axios'
import { useNavigate, useParams } from 'react-router-dom'

const EditBook = () => {

  const [title, setTitle] = useState('');
  const [author, setAuthor] = useState('');
  const [publishYear, setPublishYear] = useState('')
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { id } = useParams();

  useEffect(() => {
    setLoading(true);
    axios.get(`http://localhost:3000/books/${id}`)
      .then((response) => {
        console.log(response.data)
        setTitle(response.data.title);
        setAuthor(response.data.author);
        setPublishYear(response.data.publishYear); // Fix the typo here
        setLoading(false);
      })
      .catch((err) => {
        console.log(err);
      });
  }, [id]);


  const handleEditBook = () => {
    const data = {
      title,
      author,
      publishYear
    };

    setLoading(true);
    axios.put(`http://localhost:5000/books/${id}`, data)
      .then((response) => {
        setLoading(false);
        navigate('/')
      })
      .catch(err => {
        setLoading(false);
        alert("Error while pushing data")
        console.log(err)
      })
  }

  return (
    <div className='p-4'>
      <BackButton />
      <h1 className='text-3xl my-4'>Edit Book</h1>
      {loading ? <Snipper /> : ''}
      <div className='flex flex-col border-2 border-sky-400 rounded-xl w-[600px] p-4 mx-auto'>
        <div className='my-4'>
          <label className='text-xl mr-4 text-gray-500'>Title</label>
          <input
            type='text'
            value={title}
            onChange={e => setTitle(e.target.value)}
            className='border-2 border-gray-500 px-4 py-2 w-full'>
          </input>
        </div>

        <div className='my-4'>
          <label className='text-xl mr-4 text-gray-500'>Author</label>
          <input
            type='text'
            value={author}
            onChange={e => setAuthor(e.target.value)}
            className='border-2 border-gray-500 px-4 py-2 w-full'>
          </input>
        </div>

        <div className='my-4'>
          <label className='text-xl mr-4 text-gray-500'>Publish Year</label>
          <input
            type='text'
            value={publishYear}
            onChange={e => setPublishYear(e.target.value)}
            className='border-2 border-gray-500 px-4 py-2 w-full'>
          </input>
        </div>

        <button className='p-2 bg-sky-300 m-8' onClick={handleEditBook}>Save</button>
      </div>
    </div>
  )
}

export default EditBook