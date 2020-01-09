class Book
  attr_reader :id, :name, :genre, :isbn


  def initialize(attributes)
    @id = attributes.fetch(:id)
    @name = attributes.fetch(:name)
    @genre = attributes.fetch(:genre)
    @isbn = attributes.fetch(:isbn)
  end


  def self.all
    returned_books = DB.exec("SELECT * FROM books;")
    books = []
    returned_books.each() do |book|
      name = book.fetch("name")
      id = book.fetch("id").to_i
      genre = book.fetch("genre")
      isbn = book.fetch("isbn").to_i
      books.push(Book.new({:name => name, :id => id, :genre => genre, :isbn => isbn}))
    end
    books
  end

  def addAuthor(author_id)
    DB.exec("INSERT INTO creators (author_id, book_id) VALUES (#{author_id.to_i},#{@id});")
  end

  def save
    result = DB.exec("INSERT INTO books (name, genre, isbn) VALUES ('#{@name}', '#{@genre}', '#{isbn.to_i}' ) RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def ==(book_to_compare)
    self.name.downcase().eql?(book_to_compare.name.downcase())
  end

  def self.clear
    DB.exec("DELETE FROM books *;")
  end

  def self.find(id)
    book = DB.exec("SELECT * FROM books WHERE id = #{id};").first
    name = book.fetch("name")
    id = book.fetch("id").to_i
    genre = book.fetch("genre")
    isbn  = book.fetch("isbn")
    Book.new({:name => name, :id => id, :genre => genre, :isbn => isbn})
  end

  def self.search(name)
    book = DB.exec("SELECT * FROM books WHERE name = '#{name}'").first
    name = book.fetch("name")
    id = book.fetch("id").to_i
    genre = book.fetch("genre")
    isbn  = book.fetch("isbn")
    Book.new({:name => name, :id => id, :genre => genre, :isbn => isbn})
  end

  def self.query(name)
    search_results = []
    books = DB.exec("SELECT * FROM books WHERE name LIKE '%#{name}%';")
    books.each() do |book|
      name = book.fetch("name")
      id = book.fetch("id").to_i
      genre = book.fetch("genre")
      isbn  = book.fetch("isbn")
      search_results.push(Book.new({:name => name, :id => id, :genre => genre, :isbn => isbn}))
    end
    return search_results
  end

  def authors
    authors = []
    results = DB.exec("SELECT author_id FROM creators WHERE book_id = #{@id};")
    results.each() do |result|
      author_id = result.fetch("author_id").to_i()
      author = DB.exec("SELECT * FROM authors WHERE id = #{author_id};")
      name = author.first().fetch("name")
      bio = author.first().fetch("bio")
      authors.push(Author.new({:name => name, :id => author_id, :bio => bio}))
    end
    return authors
  end

  def is_available
    book = DB.exec("SELECT * FROM checkouts WHERE book_id = #{@id}")
    if book != nil
      return true
    else
      return false
    end
  end

  def update(attributes)
    @name = attributes.fetch(:name)
    @genre = attributes.fetch(:genre)
    @isbn = attributes.fetch(:isbn)
    DB.exec("UPDATE books SET name = '#{@name}' WHERE id = #{@id};")
    DB.exec("UPDATE books SET genre = '#{@genre}' WHERE id = #{@id};")
    DB.exec("UPDATE books SET isbn = '#{@isbn}' WHERE id = #{@id};")
  end

  def delete
    DB.exec("DELETE FROM books WHERE id = #{@id};")
  end
end
