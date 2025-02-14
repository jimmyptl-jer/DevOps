import React from 'react'
import { Route, Routes } from 'react-router-dom'
import EditBook from './pages/EditBook'
import CreateBook from './pages/CreateBook'
import DeleteBook from './pages/DeleteBook'
import ShowBook from './pages/ShowBook'
import Home from './pages/Home'


const App = () => {
  return (
    <Routes>
      <Route path='/' element={<Home></Home>}/>
      <Route path='/books/create' element={<CreateBook/>}/>
      <Route path='/books/delete/:id' element={<DeleteBook></DeleteBook>}/>
      <Route path='/books/edit/:id' element={<EditBook/>}/>
      <Route path='/books/details/:id' element={<ShowBook/>}/>
    </Routes>
  )
}

export default App